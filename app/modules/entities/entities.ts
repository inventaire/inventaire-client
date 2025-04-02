import { API } from '#app/api/api'
import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { assertObject, assertString } from '#app/lib/assert_types'
import { isPropertyUri, isEntityUri } from '#app/lib/boolean_tests'
import { serverReportError, newError, type ContextualizedError } from '#app/lib/error'
import type { ProjectRootRelativeUrl } from '#app/lib/location'
import preq from '#app/lib/preq'
import { getAllQuerystringParameters, getQuerystringParameter } from '#app/lib/querystring_helpers'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { type SerializedEntity, type SerializedWdEntity, getEntityByUri, normalizeUri } from '#entities/lib/entities'
import { entityTypeNameBySingularType } from '#entities/lib/types/entities_types'
import { showItemCreationForm } from '#inventory/lib/show_item_creation_form'
import type { AccessLevel } from '#server/lib/user_access_levels'
import type { WdEntityUri, EntityUri, SimplifiedClaims } from '#server/types/entity'
import { i18n, I18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'
import { entityDataShouldBeRefreshed, startRefreshTimeSpan } from './lib/entity_refresh.ts'
import { getEntityLayoutComponentByType } from './lib/get_entity_layout_component_by_type.ts'
import type { ComponentType, ComponentProps, SvelteComponent } from 'svelte'

export default {
  initialize () {
    addRoutes({
      '/entity/new(/)': 'showEntityCreateFromRoute',
      '/entity/changes(/)': 'showChanges',
      '/entity/contributions(/)': 'showContributionsCounts',
      '/entity/deduplicate(/authors)(/)': 'showDeduplicateAuthors',
      '/entity/merge(/)': 'showEntityMerge',
      '/entity/:uri/add(/)': 'showAddEntity',
      '/entity/:uri/edit(/)': 'showEditEntityFromUri',
      '/entity/:uri/cleanup(/)': 'showEntityCleanup',
      '/entity/:uri/homonyms(/)': 'showHomonyms',
      '/entity/:uri/deduplicate(/)': 'showEntityDeduplicate',
      '/entity/:uri/history(/)': 'showEntityHistory',
      '/entity/:uri(/)': 'showEntity',
    }, controller)

    setHandlers()
  },
}

const controller = {
  async showEntity (input: string, params?) {
    let uri
    if (input.includes('-')) {
      const [ property, entity ] = input.split('-')
      uri = `${property}-${normalizeUri(entity)}`
    } else {
      uri = normalizeUri(input)
    }

    const refresh = params?.refresh || getQuerystringParameter('refresh') || entityDataShouldBeRefreshed(uri)
    if (refresh) startRefreshTimeSpan(uri)
    if (isClaim(uri)) return showClaimEntities(uri, refresh)

    const pathname = `/entity/${uri}`
    if (!isEntityUri(uri)) return commands.execute('show:error:missing', { pathname })

    commands.execute('show:loader')

    try {
      const entity = await getEntityByUri({ uri, refresh })
      rejectRemovedPlaceholder(entity)
      const { Component, props } = await getEntityLayoutComponentByType(entity)
      appLayout.showChildComponent('main', Component, { props })
    } catch (err) {
      handleMissingEntity(uri, err)
    }
  },

  async showAddEntity (input: string) {
    const uri = normalizeUri(input)
    try {
      const entity = await getEntityByUri({ uri })
      await showItemCreationForm({ entity })
    } catch (err) {
      handleMissingEntity(uri, err)
    }
  },

  async showEditEntityFromUri (input: string) {
    commands.execute('show:loader')
    const uri = normalizeUri(input)

    try {
      // Make sure we have the freshest data before trying to edit (refresh=true)
      // but prevent triggering an auto update (autocreate=false)
      // Maybe the server should allow to set autocreate=true&autoedit=false
      // to fetch authorities data only in cases where no entity was found
      const entity = await getEntityByUri({ uri, refresh: true, autocreate: false })
      await showEntityEdit(entity)
    } catch (err) {
      handleMissingEntity(uri, err)
    }
  },

  async showEntityCreateFromRoute () {
    try {
      if (reqres.request('require:loggedIn', 'entity/new')) {
        const { label, type, claims } = getAllQuerystringParameters()
        assertString(label)
        if (type) assertString(type)
        if (claims) assertObject(claims)
        await showEntityCreate({ type: type as string, label, claims })
      }
    } catch (err) {
      commands.execute('show:error', err)
    }
  },

  async showChanges () {
    if (!reqres.request('require:loggedIn', 'entity/changes')) return
    if (!reqres.request('require:admin:access')) return
    const { default: Contributions } = await import('#entities/components/patches/contributions.svelte')
    appLayout.showChildComponent('main', Contributions)
    app.navigate('entity/changes', { metadata: { title: i18n('recent changes') } })
  },

  async showContributionsCounts () {
    const { default: ContributionsCounts } = await import('./components/contributions_counts.svelte')
    showComponentByAccessLevel({
      path: 'entity/contributions',
      title: 'contributions',
      Component: ContributionsCounts,
      accessLevel: 'admin',
    })
  },

  async showDeduplicateAuthors () {
    const { default: DeduplicateAuthorsNames } = await import('./components/deduplicate_authors_names.svelte')
    showComponentByAccessLevel({
      path: 'entity/deduplicate/authors',
      title: `${i18n('deduplicate')} - ${i18n('authors')}`,
      Component: DeduplicateAuthorsNames,
      navigate: true,
      accessLevel: 'dataadmin',
    })
  },

  async showEntityDeduplicate (input: string) {
    const uri = normalizeUri(input)
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
      commands.execute('show:error', err)
      return
    }

    showComponentByAccessLevel({
      path: `entity/${uri}/deduplicate`,
      title: `${entity.label} - ${i18n('deduplicate')} - ${i18n('works')}`,
      Component: DeduplicateWorks,
      componentProps: { author: entity },
      accessLevel: 'dataadmin',
    })
  },

  async showEntityCleanup  (input: string) {
    const uri = normalizeUri(input)
    if (reqres.request('require:loggedIn', `entity/${uri}/cleanup`)) {
      commands.execute('show:loader')
      try {
        const entity = await getEntityByUri({ uri, refresh: true })
        showEntityCleanup(entity)
      } catch (err) {
        handleMissingEntity(uri, err)
      }
    }
  },

  async showHomonyms (input: string) {
    const uri = normalizeUri(input)
    if (!reqres.request('require:loggedIn', `entity/${uri}/homonyms`)) return
    if (!reqres.request('require:dataadmin:access')) return

    commands.execute('show:loader')
    const [
      { default: HomonymDeduplicates },
      entity,
    ] = await Promise.all([
      import('./components/layouts/deduplicate_homonyms.svelte'),
      getEntityByUri({ uri }),
    ])
    appLayout.showChildComponent('main', HomonymDeduplicates, {
      props: {
        entity,
        standalone: true,
      },
    })
  },

  async showEntityHistory (input: string) {
    commands.execute('show:loader')
    const uri = normalizeUri(input)
    const { default: EntityHistory } = await import('./components/patches/entity_history.svelte')
    appLayout.showChildComponent('main', EntityHistory, {
      props: { uri },
    })
  },

  async showEntityMerge () {
    const { from, to, type } = getAllQuerystringParameters()
    commands.execute('show:loader')
    const { default: EntityMerge } = await import('./components/entity_merge.svelte')
    appLayout.showChildComponent('main', EntityMerge, {
      props: { from, to, type },
    })
  },
} as const

export async function showEntityCreate (params: { label: string, type?: string, claims?: SimplifiedClaims }) {
  const path = 'entity/new'
  if (!reqres.request('require:loggedIn', path)) return
  app.navigate(path)

  // Drop possible type pluralization
  params.type = params.type?.replace(/s$/, '')

  // Known case: when clicking 'create' while live search section is 'subject'
  if (entityTypeNameBySingularType[params.type] == null) {
    params.type = null
  }
  if (params.type) commands.execute('querystring:set', 'type', params.type)
  if (params.claims) commands.execute('querystring:set', 'claims', params.claims)

  const { default: EntityCreate } = await import('./components/editor/entity_create.svelte')
  appLayout.showChildComponent('main', EntityCreate, {
    props: params,
  })
}

function setHandlers () {
  commands.setHandlers({
    'show:entity': controller.showEntity.bind(controller),
    'show:entity:edit': controller.showEditEntityFromUri,
    'show:entity:cleanup': controller.showEntityCleanup,
    'show:entity:history': controller.showEntityHistory,
    'show:wikidata:edit:intro': async (uri: WdEntityUri) => {
      const entity = await getEntityByUri({ uri })
      showWikidataEditIntro(entity)
    },
  })
}

async function showEntityEdit (entity: SerializedEntity) {
  if (!entity) return commands.execute('show:error:missing')
  const { uri, type, label, editPathname } = entity
  if (!editPathname) {
    throw newError('this entity can not be edited', 400, { uri, type })
  }
  if (!reqres.request('require:loggedIn', editPathname)) return

  rejectRemovedPlaceholder(entity)

  if (type == null) throw newError('invalid entity type', 400, { entity })
  const { default: EntityEdit } = await import('./components/editor/entity_edit.svelte')
  appLayout.showChildComponent('main', EntityEdit, {
    props: {
      entity,
    },
  })
  app.navigate(editPathname, { metadata: { title: `${label} - ${i18n('edit')}` } })
}

async function showWikidataEditIntro (entity: SerializedWdEntity) {
  const { default: WikidataEditIntro } = await import('./components/wikidata_edit_intro.svelte')
  appLayout.showChildComponent('main', WikidataEditIntro, { props: { entity } })
}

function rejectRemovedPlaceholder (entity: SerializedEntity) {
  if ('_meta_type' in entity && entity._meta_type === 'removed:placeholder') {
    throw newError('removed placeholder', 400, { entity })
  }
}

function handleMissingEntity (uri: EntityUri, err: ContextualizedError) {
  if (err.message === 'invalid entity type') {
    commands.execute('show:error:other', err)
  } else if (err.code === 'entity_not_found') {
    const [ prefix, id ] = uri.split(':')
    const pathname = `/entity/${uri}`
    if (mainUser && prefix === 'isbn') showEntityCreateFromIsbn(id)
    else commands.execute('show:error:missing', { pathname })
  } else {
    commands.execute('show:error:other', err, 'handleMissingEntity')
  }
}

async function showEntityCreateFromIsbn (isbn) {
  const isbnData = await preq.get(API.data.isbn(isbn))

  const { isbn13h, groupLangUri } = isbnData
  const claims = { 'wdt:P212': [ isbn13h ] }
  if (isEntityUri(groupLangUri)) {
    claims['wdt:P407'] = [ groupLangUri ]
  }

  const { default: EntityCreateEditionAndWorkFromIsbn } = await import('./components/editor/entity_create_edition_and_work_from_isbn.svelte')
  appLayout.showChildComponent('main', EntityCreateEditionAndWorkFromIsbn, {
    props: {
      isbn13h,
      edition: { claims },
    },
  })
}

interface ShowComponentByAccessLevelParams {
  path: ProjectRootRelativeUrl
  title: string
  Component: ComponentType
  componentProps?: ComponentProps<SvelteComponent>
  navigate?: boolean
  accessLevel: AccessLevel
}

function showComponentByAccessLevel (params: ShowComponentByAccessLevelParams) {
  let { path, title, Component, componentProps, navigate, accessLevel } = params
  if (navigate == null) navigate = true
  if (reqres.request('require:loggedIn', path)) {
    if (navigate) app.navigate(path, { metadata: { title } })
    if (reqres.request(`require:${accessLevel}:access`)) {
      appLayout.showChildComponent('main', Component, {
        props: componentProps,
      })
    }
  }
}

const isClaim = claim => /^(wdt:|invp:)/.test(claim)

async function showClaimEntities (claim, refresh) {
  const [ property, value ] = claim.split('-')
  const pathname = `/entity/${claim}`

  if (!isPropertyUri(property)) {
    serverReportError('invalid property')
    commands.execute('show:error:missing', { pathname })
    return
  }

  if (!isEntityUri(value)) {
    serverReportError('invalid value')
    commands.execute('show:error:missing', { pathname })
    return
  }

  const { default: ClaimLayout } = await import('#entities/components/layouts/claim_layout.svelte')
  const entity = await getEntityByUri({ uri: value, refresh })
  appLayout.showChildComponent('main', ClaimLayout, {
    props: {
      property,
      entity,
    },
  })
}

async function showEntityCleanup (entity: SerializedEntity) {
  if (entity.type !== 'serie') {
    const err = newError(`cleanup isn't available for entity type ${entity.type}`, 400)
    commands.execute('show:error', err)
    return
  }
  const [ { default: SerieCleanup } ] = await Promise.all([
    import('./components/cleanup/serie_cleanup.svelte'),
  ])
  appLayout.showChildComponent('main', SerieCleanup, {
    props: { serie: entity },
  })
  app.navigate(entity.cleanupPathname, { metadata: { title: `${entity.label} - ${I18n('cleanup')}` } })
}
