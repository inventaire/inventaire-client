import { isPropertyUri, isExtendedEntityUri, isEntityUri } from '#lib/boolean_tests'
import assert_ from '#lib/assert_types'
import { forceArray } from '#lib/utils'
import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { i18n } from '#user/lib/i18n'
import error_ from '#lib/error'
import entityDraftModel from './lib/entity_draft_model.js'
import * as entitiesModelsIndex from './lib/entities_models_index.js'
import getEntityViewByType from './lib/get_entity_view_by_type.js'
import { getEntityByUri, normalizeUri } from './lib/entities.js'
import showHomonyms from './lib/show_homonyms.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'entity/new(/)': 'showEntityCreateFromRoute',
        'entity/changes(/)': 'showChanges',
        'entity/contributions(/)': 'showContributions',
        'entity/deduplicate(/authors)(/)': 'showDeduplicateAuthors',
        'entity/:uri/add(/)': 'showAddEntity',
        'entity/:uri/edit(/)': 'showEditEntityFromUri',
        'entity/:uri/cleanup(/)': 'showEntityCleanup',
        'entity/:uri/homonyms(/)': 'showHomonyms',
        'entity/:uri/deduplicate(/)': 'showEntityDeduplicate',
        'entity/:uri/history(/)': 'showEntityHistory',
        'entity/:uri(/)': 'showEntity'
      }
    })

    new Router({ controller: API })

    setHandlers()
  }
}

const API = {
  async showEntity (uri, params) {
    const refresh = params?.refresh || app.request('querystring:get', 'refresh')
    if (isClaim(uri)) return showClaimEntities(uri, refresh)

    uri = normalizeUri(uri)
    const pathname = `/entity/${uri}`
    if (!isExtendedEntityUri(uri)) return app.execute('show:error:missing', { pathname })

    app.execute('show:loader')

    if (refresh) app.execute('uriLabel:refresh')

    try {
      const entity = await getEntityModel(uri, refresh)
      rejectRemovedPlaceholder(entity)

      const view = await getEntityViewByType(entity, refresh)
      app.layout.showChildView('main', view)
      app.navigateFromModel(entity)
    } catch (err) {
      handleMissingEntity(uri, err)
    }
  },

  async showAddEntity (uri) {
    uri = normalizeUri(uri)
    try {
      const entity = await getEntityModel(uri)
      app.execute('show:item:creation:form', { entity })
    } catch (err) {
      handleMissingEntity(uri, err)
    }
  },

  async showEditEntityFromUri (uri) {
    app.execute('show:loader')
    uri = normalizeUri(uri)

    // Make sure we have the freshest data before trying to edit
    return getEntityModel(uri, true)
    .then(showEntityEditFromModel)
    .catch(handleMissingEntity.bind(null, uri))
  },

  showEntityCreateFromRoute () {
    if (app.request('require:loggedIn', 'entity/new')) {
      const params = app.request('querystring:get:all')
      if (params.allowToChangeType == null && !params.next) {
        params.allowToChangeType = true
      }
      return showEntityCreate(params)
    }
  },

  async showChanges () {
    if (!app.request('require:loggedIn', 'entity/changes')) return
    if (!app.request('require:admin:access')) return
    const { default: Contributions } = await import('#users/views/contributions')
    app.layout.showChildView('main', new Contributions())
    app.navigate('entity/changes', { metadata: { title: i18n('recent changes') } })
  },

  async showContributions () {
    const { default: Contributions } = await import('./components/contributions.svelte')
    showViewByAccessLevel({
      path: 'entity/contributions',
      title: 'contributions',
      Component: Contributions,
      accessLevel: 'admin'
    })
  },

  // Do not use default parameter `(params = {})`
  // as the router might pass `null` as first argument
  async showDeduplicateAuthors (params) {
    params = params || {}
    // Using an object interface, as the router might pass querystrings
    let { uris } = params
    uris = forceArray(uris)
    const { default: DeduplicateAuthors } = await import('./components/deduplicate_authors.svelte')
    showViewByAccessLevel({
      path: 'entity/deduplicate/authors',
      title: `${i18n('deduplicate')} - ${i18n('authors')}`,
      Component: DeduplicateAuthors,
      componentProps: { uris },
      // Assume that if uris are passed, navigate was already done
      // to avoid double navigation
      navigate: (uris == null),
      accessLevel: 'dataadmin'
    })
  },

  async showEntityDeduplicate (uri) {
    const [
      entity,
      { default: DeduplicateWorks },
    ] = await Promise.all([
      getEntityByUri({ uri }),
      import('./components/deduplicate_works.svelte'),
    ])

    const { type } = entity
    if (type !== 'human') {
      const err = new Error(`case not handled yet: ${type}`)
      app.execute('show:error', err)
      return
    }

    showViewByAccessLevel({
      path: `entity/${uri}/deduplicate`,
      title: `${entity.label} - ${i18n('deduplicate')} - ${i18n('works')}`,
      Component: DeduplicateWorks,
      componentProps: { author: entity },
      accessLevel: 'dataadmin'
    })
  },

  showEntityCleanup (uri) {
    if (app.request('require:loggedIn', `entity/${uri}/cleanup`)) {
      app.execute('show:loader')
      uri = normalizeUri(uri)

      return getEntityModel(uri, true)
      .then(showEntityCleanupFromModel)
      .catch(handleMissingEntity.bind(null, uri))
    }
  },

  async showHomonyms (uri) {
    if (!app.request('require:loggedIn', `entity/${uri}/homonyms`)) return
    if (!app.request('require:admin:access')) return

    const model = await getEntityModel(uri, true)
    app.execute('show:homonyms', {
      model,
      layout: app.layout,
      regionName: 'main',
      standalone: true
    })
  },

  async showEntityHistory (uri) {
    app.execute('show:loader')

    uri = normalizeUri(uri)

    const model = await getEntityModel(uri)

    try {
      const [ { default: History } ] = await Promise.all([
        import('./views/editor/history'),
        model.fetchHistory(uri)
      ])
      app.layout.showChildView('main', new History({ model, standalone: true, uri }))
      if (uri === model.get('uri')) {
        app.navigateFromModel(model, 'history')
      // Case where we got a redirected uri
      } else {
        app.navigate(`entity/${uri}/history`)
      }
    } catch (err) {
      app.execute('show:error', err)
    }
  }
}

const showEntityCreate = async params => {
  // Drop possible type pluralization
  params.type = params.type?.replace(/s$/, '')

  // Known case: when clicking 'create' while live search section is 'subject'
  if (!entityDraftModel.allowlistedTypes.includes(params.type)) {
    params.type = null
  }

  if ((params.type != null) && !params.allowToChangeType) {
    params.model = entityDraftModel.create(params)
    return showEntityEdit(params)
  } else {
    const { default: EntityCreate } = await import('./views/editor/entity_create')
    app.layout.showChildView('main', new EntityCreate(params))
  }
}

const setHandlers = function () {
  app.commands.setHandlers({
    'show:entity': API.showEntity.bind(API),
    'show:claim:entities' (property, value) {
      const claim = `${property}-${value}`
      API.showEntity(claim)
      app.navigate(`entity/${claim}`)
    },

    'show:entity:from:model' (model, params) {
      const uri = model.get('uri')
      if (uri != null) {
        app.execute('show:entity', uri, params)
      } else {
        throw new Error("couldn't show:entity:from:model")
      }
    },

    'show:entity:refresh' (model) {
      app.execute('show:entity:from:model', model, { refresh: true })
    },

    'show:deduplicate:sub:entities' (model) {
      const uri = model.get('uri')
      API.showEntityDeduplicate(uri)
    },

    'show:entity:add': API.showAddEntity.bind(API),
    'show:entity:add:from:model' (model) { return API.showAddEntity(model.get('uri')) },
    'show:entity:edit': API.showEditEntityFromUri,
    'show:entity:edit:from:model' (model) {
      // Uses API.showEditEntityFromUri the fetch fresh entity data
      return API.showEditEntityFromUri(model.get('uri'))
    },
    'show:entity:edit:from:params': showEntityEdit,
    'show:entity:create': showEntityCreate,
    'show:entity:cleanup': API.showEntityCleanup,
    'show:entity:history': API.showEntityHistory,
    'show:homonyms': showHomonyms,
    'report:entity:type:issue': reportTypeIssue,
    'show:wikidata:edit:intro:modal': showWikidataEditIntroModal
  })

  app.reqres.setHandlers({
    'get:entity:model': getEntityModel,
    'get:entities:models': getEntitiesModels,
    'get:entity:local:href': getEntityLocalHref,
    'entity:exists:or:create:from:seed': existsOrCreateFromSeed
  })
}

const getEntitiesModels = async function (params) {
  let { uris, refresh, defaultType, index } = params
  assert_.array(uris)
  assert_.strings(uris)
  // Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh === true

  if (uris.length === 0) return []

  const models = await entitiesModelsIndex.get({ uris, refresh, defaultType })
  if (index) return models
  // Do not return entities with type 'missing'.
  // This type is used to avoid re-fetching an entity already known to be missing
  // but has no interest past entitiesModelsIndex
  else return _.values(models).filter(isntMissing)
}

// Known case of model being undefined: when the model initialization failed
const isntMissing = model => (model != null) && (model?.type !== 'missing')

const getEntityModel = async (uri, refresh) => {
  const [ model ] = await getEntitiesModels({ uris: [ uri ], refresh })
  if (model != null) {
    return model
  } else {
    // See getEntitiesModels "Possible reasons for missing entities"
    log_.info(`getEntityModel entity_not_found: ${uri}`)
    throw error_.new('entity_not_found', [ uri, model ])
  }
}

const getEntityLocalHref = uri => `/entity/${uri}`

const showEntityEdit = async params => {
  const { model, layout, regionName } = params
  if (model.type == null) throw error_.new('invalid entity type', model)
  if (params.next != null || params.previous != null) {
    const { default: View } = await import('./views/editor/multi_entity_edit')
    app.layout.showChildView('main', new View(params))
  } else if (layout && regionName) {
    const { default: View } = await import('./views/editor/entity_edit')
    layout.showChildView(regionName, new View(params))
  } else {
    const { default: EntityEdit } = await import('./components/editor/entity_edit.svelte')
    app.layout.getRegion('main').showSvelteComponent(EntityEdit, {
      props: {
        entity: model.toJSON()
      }
    })
  }
  app.navigateFromModel(model, 'edit')
}

const showEntityEditFromModel = async model => {
  const editRoute = model.get('edit')
  if (!editRoute) {
    const { uri, type } = model.toJSON()
    throw error_.new('this entity can not be edited', 400, { uri, type })
  }
  if (!app.request('require:loggedIn', model.get('edit'))) return

  rejectRemovedPlaceholder(model)

  const prefix = model.get('prefix')
  if ((prefix === 'wd') && !app.user.hasWikidataOauthTokens()) {
    return showWikidataEditIntroModal(model)
  } else {
    return showEntityEdit({ model })
  }
}

const showWikidataEditIntroModal = async model => {
  const { default: WikidataEditIntro } = await import('./views/wikidata_edit_intro')
  app.layout.showChildView('modal', new WikidataEditIntro({ model }))
}

const rejectRemovedPlaceholder = function (entity) {
  if (entity.get('_meta_type') === 'removed:placeholder') {
    throw error_.new('removed placeholder', 400, { entity })
  }
}

const handleMissingEntity = (uri, err) => {
  if (err.message === 'invalid entity type') {
    app.execute('show:error:other', err)
  } else if (err.message === 'entity_not_found') {
    const [ prefix, id ] = uri.split(':')
    const pathname = `/entity/${uri}`
    if (prefix === 'isbn') showEntityCreateFromIsbn(id)
    else app.execute('show:error:missing', { pathname })
  } else {
    app.execute('show:error:other', err, 'handleMissingEntity')
  }
}

const showEntityCreateFromIsbn = isbn => {
  return preq.get(app.API.data.isbn(isbn))
  .then(isbnData => {
    const { isbn13h, groupLangUri } = isbnData
    const claims = { 'wdt:P212': [ isbn13h ] }
    // TODO: try to deduce publisher from ISBN publisher section
    if (isEntityUri(groupLangUri)) claims['wdt:P407'] = [ groupLangUri ]

    // Start by requesting the creation of a work entity
    return showEntityCreate({
      fromIsbn: isbn,
      type: 'work',
      // on which will be based an edition entity
      next: {
        // The work entity should be used as 'edition of' value
        relation: 'wdt:P629',
        // The work label should be used as edition title suggestion
        labelTransfer: 'wdt:P1476',
        type: 'edition',
        claims
      }
    })
  })
  .catch(err => app.execute('show:error:other', err, 'showEntityCreateFromIsbn'))
}

// Create from the seed data we have, if the entity isn't known yet
const existsOrCreateFromSeed = async entry => {
  const { entries } = await preq.post(app.API.entities.resolve, {
    entries: [ entry ],
    update: true,
    create: true,
    enrich: true
  })
  // Add the possibly newly created edition entity to the local index
  // and get it's model
  const { uri } = entries[0].edition
  return getEntityModel(uri, true)
}

const showViewByAccessLevel = function (params) {
  let { path, title, View, viewOptions, Component, componentProps, navigate, accessLevel } = params
  if (navigate == null) navigate = true
  if (app.request('require:loggedIn', path)) {
    if (navigate) app.navigate(path, { metadata: { title } })
    if (app.request(`require:${accessLevel}:access`)) {
      if (View) {
        app.layout.showChildView('main', new View(viewOptions))
      } else {
        app.layout.getRegion('main').showSvelteComponent(Component, {
          props: componentProps
        })
      }
    }
  }
}

const isClaim = claim => /^(wdt:|invp:)/.test(claim)

const showClaimEntities = async (claim, refresh) => {
  const [ property, value ] = claim.split('-')
  const pathname = `/entity/${claim}`

  if (!isPropertyUri(property)) {
    error_.report('invalid property')
    app.execute('show:error:missing', { pathname })
    return
  }

  if (!isExtendedEntityUri(value)) {
    error_.report('invalid value')
    app.execute('show:error:missing', { pathname })
    return
  }

  const { default: ClaimLayout } = await import('./views/claim_layout')

  app.layout.showChildView('main', new ClaimLayout({ property, value, refresh }))
}

const reportTypeIssue = function (params) {
  const { expectedType, model, context } = params
  const [ uri, realType ] = model.gets('uri', 'type')
  if (reportedTypeIssueUris.includes(uri)) return
  reportedTypeIssueUris.push(uri)

  const subject = `[Entity type] ${uri}: expected ${expectedType}, got ${realType}`
  app.request('post:feedback', { subject, uris: [ uri ], context })
}

const reportedTypeIssueUris = []

const showEntityCleanupFromModel = async entity => {
  if (entity.type !== 'serie') {
    const err = error_.new(`cleanup isn't available for entity type ${entity.type}`, 400)
    app.execute('show:error', err)
    return
  }

  const [ { default: SerieCleanup } ] = await Promise.all([
    import('./views/cleanup/serie_cleanup'),
    entity.initSerieParts({ refresh: true, fetchAll: true })
  ])

  app.layout.showChildView('main', new SerieCleanup({ model: entity }))
  app.navigateFromModel(entity, 'cleanup')
}
