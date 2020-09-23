import error_ from 'lib/error';
import Entity from './models/entity';
import SerieCleanup from './views/cleanup/serie_cleanup';
import WorkLayout from './views/work_layout';
import EntityEdit from './views/editor/entity_edit';
import EntityCreate from './views/editor/entity_create';
import MultiEntityEdit from './views/editor/multi_entity_edit';
import entityDraftModel from './lib/entity_draft_model';
import entitiesModelsIndex from './lib/entities_models_index';
import ChangesLayout from './views/changes_layout';
import ActivityLayout from './views/activity_layout';
import ClaimLayout from './views/claim_layout';
import DeduplicateLayout from './views/deduplicate_layout';
import WikidataEditIntro from './views/wikidata_edit_intro';
import History from './views/editor/history';
import getEntityViewByType from './lib/get_entity_view_by_type';
import { normalizeUri } from './lib/entities';

export default {
  define(module, app, Backbone, Marionette, $, _){
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'entity/new(/)': 'showEntityCreateFromRoute',
        'entity/changes(/)': 'showChanges',
        'entity/activity(/)': 'showActivity',
        'entity/deduplicate(/)': 'showDeduplicate',
        'entity/:uri/add(/)': 'showAddEntity',
        'entity/:uri/edit(/)': 'showEditEntityFromUri',
        'entity/:uri/cleanup(/)': 'showEntityCleanup',
        'entity/:uri/deduplicate(/)': 'showEntityDeduplicate',
        'entity/:uri/history(/)': 'showEntityHistory',
        'entity/:uri(/)': 'showEntity'
      }
    });

    return app.addInitializer(() => new Router({ controller: API }));
  },

  initialize() {
    return setHandlers();
  }
};

var API = {
  showEntity(uri, params){
    const refresh = params?.refresh || app.request('querystring:get', 'refresh');
    if (isClaim(uri)) { return showClaimEntities(uri, refresh); }

    uri = normalizeUri(uri);
    if (!_.isExtendedEntityUri(uri)) { return app.execute('show:error:missing'); }

    app.execute('show:loader');

    if (refresh) { app.execute('uriLabel:refresh'); }

    return getEntityModel(uri, refresh)
    .then(function(entity){
      rejectRemovedPlaceholder(entity);

      return getEntityViewByType(entity, refresh)
      .then(function(view){
        app.layout.main.show(view);
        return app.navigateFromModel(entity);
      });}).catch(handleMissingEntity(uri));
  },

  showAddEntity(uri){
    uri = normalizeUri(uri);
    return getEntityModel(uri)
    .then(entity => app.execute('show:item:creation:form', { entity }))
    .catch(handleMissingEntity(uri));
  },

  showEditEntityFromUri(uri){
    app.execute('show:loader');
    uri = normalizeUri(uri);

    // Make sure we have the freshest data before trying to edit
    return getEntityModel(uri, true)
    .then(showEntityEditFromModel)
    .catch(handleMissingEntity(uri));
  },

  showEntityCreateFromRoute() {
    if (app.request('require:loggedIn', 'entity/new')) {
      const params = app.request('querystring:get:all');
      if (params.allowToChangeType == null) { params.allowToChangeType = true; }
      return showEntityCreate(params);
    }
  },

  showChanges() {
    app.layout.main.show(new ChangesLayout);
    return app.navigate('entity/changes', { metadata: { title: 'changes' } });
  },

  showActivity() {
    return showViewByAccessLevel({
      path: 'entity/activity',
      title: 'activity',
      View: ActivityLayout,
      accessLevel: 'admin'
    });
  },

  showDeduplicate(params = {}){
    // Using an object interface, as the router might pass querystrings
    let { uris } = params;
    uris = _.forceArray(uris);
    return showViewByAccessLevel({
      path: 'entity/deduplicate',
      title: 'deduplicate',
      View: DeduplicateLayout,
      viewOptions: { uris },
      // Assume that if uris are passed, navigate was already done
      // to avoid double navigation
      navigate: (uris == null),
      accessLevel: 'dataadmin'
    });
  },

  showEntityCleanup(uri){
    if (app.request('require:loggedIn', `entity/${uri}/cleanup`)) {
      app.execute('show:loader');
      uri = normalizeUri(uri);

      return getEntityModel(uri, true)
      .then(showEntityCleanupFromModel)
      .catch(handleMissingEntity(uri));
    }
  },

  showEntityDeduplicate(uri){
    if (!app.request('require:loggedIn', `entity/${uri}/deduplicate`)) { return; }
    if (!app.request('require:admin:access')) { return; }

    return getEntityModel(uri, true)
    .then(model => app.execute('show:merge:suggestions', { model, region: app.layout.main, standalone: true }));
  },

  showEntityHistory(uri){
    if (!app.request('require:loggedIn', `entity/${uri}/history`)) { return; }
    if (!app.request('require:admin:access')) { return; }

    uri = normalizeUri(uri);

    return getEntityModel(uri)
    .then(model => model.fetchHistory(uri)
    .then(function() {
      app.layout.main.show(new History({ model, standalone: true, uri }));
      if (uri === model.get('uri')) { return app.navigateFromModel(model, 'history');
      // Case where we got a redirected uri
      } else { return app.navigate(`entity/${uri}/history`); }
    })).catch(app.Execute('show:error'));
  }
};

var showEntityCreate = function(params){
  // Drop possible type pluralization
  params.type = params.type?.replace(/s$/, '');

  // Known case: when clicking 'create' while live search section is 'subject'
  if (!entityDraftModel.allowlistedTypes.includes(params.type)) {
    params.type = null;
  }

  if ((params.type != null) && !params.allowToChangeType) {
    params.model = entityDraftModel.create(params);
    return showEntityEdit(params);
  } else {
    return app.layout.main.show(new EntityCreate(params));
  }
};

var setHandlers = function() {
  app.commands.setHandlers({
    'show:entity': API.showEntity.bind(API),
    'show:claim:entities'(property, value){
      const claim = `${property}-${value}`;
      API.showEntity(claim);
      return app.navigate(`entity/${claim}`);
    },

    'show:entity:from:model'(model, params){
      const uri = model.get('uri');
      if (uri != null) { return app.execute('show:entity', uri, params);
      } else { throw new Error("couldn't show:entity:from:model"); }
    },

    'show:entity:refresh'(model){
      return app.execute('show:entity:from:model', model, { refresh: true });
    },

    'show:deduplicate:sub:entities'(model, options = {}){
      const { openInNewTab } = options;
      const uri = model.get('uri');
      const pathname = '/entity/deduplicate?uris=' + uri;
      if (openInNewTab) {
        return window.open(pathname, '_blank');
      } else {
        API.showDeduplicate({ uris: [ uri ] });
        return app.navigate(pathname);
      }
    },

    'show:entity:add': API.showAddEntity.bind(API),
    'show:entity:add:from:model'(model){ return API.showAddEntity(model.get('uri')); },
    'show:entity:edit': API.showEditEntityFromUri,
    'show:entity:edit:from:model'(model){
      // Uses API.showEditEntityFromUri the fetch fresh entity data
      return API.showEditEntityFromUri(model.get('uri'));
    },
    'show:entity:edit:from:params': showEntityEdit,
    'show:entity:create': showEntityCreate,
    'show:entity:cleanup': API.showEntityCleanup,
    'show:merge:suggestions': require('./lib/show_merge_suggestions'),
    'report:entity:type:issue': reportTypeIssue,
    'show:wikidata:edit:intro:modal': showWikidataEditIntroModal
  });

  return app.reqres.setHandlers({
    'get:entity:model': getEntityModel,
    'get:entities:models': getEntitiesModels,
    'get:entity:local:href': getEntityLocalHref,
    'entity:exists:or:create:from:seed': existsOrCreateFromSeed
  });
};

var getEntitiesModels = function(params){
  let { uris, refresh, defaultType, index } = params;
  _.type(uris, 'array');
  _.types(uris, 'strings...');
  // Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh === true;

  if (uris.length === 0) { return Promise.resolve([]); }

  return entitiesModelsIndex.get({ uris, refresh, defaultType })
  // Do not return entities with type 'missing'.
  // This type is used to avoid re-fetching an entity already known to be missing
  // but has no interest past entitiesModelsIndex
  .then(function(models){
    if (index) { return models;
    } else { return _.values(models).filter(isntMissing); }
  });
};

// Known case of model being undefined: when the model initialization failed
var isntMissing = model => (model != null) && (model?.type !== 'missing');

var getEntityModel = (uri, refresh) => getEntitiesModels({ uris: [ uri ], refresh })
.then(function(models){
  const model = models[0];
  if (model != null) {
    return model;
  } else {
    // see getEntitiesModels "Possible reasons for missing entities"
    _.log(`getEntityModel entity_not_found: ${uri}`);
    throw error_.new('entity_not_found', [ uri, models ]);
  }});

var getEntityLocalHref = uri => `/entity/${uri}`;

var showEntityEdit = function(params){
  let { model, region } = params;
  if (model.type == null) { throw error_.new('invalid entity type', model); }
  const View = (params.next != null) || (params.previous != null) ? MultiEntityEdit : EntityEdit;
  if (!region) { region = app.layout.main; }
  region.show(new View(params));
  return app.navigateFromModel(model, 'edit');
};

var showEntityEditFromModel = function(model){
  if (!app.request('require:loggedIn', model.get('edit'))) { return; }

  rejectRemovedPlaceholder(model);

  const prefix = model.get('prefix');
  if ((prefix === 'wd') && !app.user.hasWikidataOauthTokens()) {
    return showWikidataEditIntroModal(model);
  } else {
    return showEntityEdit({ model });
  }
};

var showWikidataEditIntroModal = model => app.layout.modal.show(new WikidataEditIntro({ model }));

var rejectRemovedPlaceholder = function(entity){
  if (entity.get('_meta_type') === 'removed:placeholder') {
    throw error_.new('removed placeholder', 400, { entity });
  }
};

var handleMissingEntity = uri => (function(err) {
  switch (err.message) {
    case 'invalid entity type':
      return app.execute('show:error:other', err);
    case 'entity_not_found':
      var [ prefix, id ] = Array.from(uri.split(':'));
      if (prefix === 'isbn') { return showEntityCreateFromIsbn(id);
      } else { return app.execute('show:error:missing'); }
    default:
      return app.execute('show:error:other', err, 'handleMissingEntity');
  }
});

var showEntityCreateFromIsbn = isbn => _.preq.get(app.API.data.isbn(isbn))
.then(function(isbnData){
  const { isbn13h, groupLangUri } = isbnData;
  const claims = { 'wdt:P212': [ isbn13h ] };
  // TODO: try to deduce publisher from ISBN publisher section
  if (_.isEntityUri(groupLangUri)) { claims['wdt:P407'] = [ groupLangUri ]; }

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
  });}).catch(err => app.execute('show:error:other', err, 'showEntityCreateFromIsbn'));

// Create from the seed data we have, if the entity isn't known yet
var existsOrCreateFromSeed = entry => _.preq.post(app.API.entities.resolve, { entries: [ entry ], update: true, create: true, enrich: true })
// Add the possibly newly created edition entity to the local index
// and get it's model
.get('entries')
.then(function(entries){
  const { uri } = entries[0].edition;
  return getEntityModel(uri, true);
});

var showViewByAccessLevel = function(params){
  let { path, title, View, viewOptions, navigate, accessLevel } = params;
  if (navigate == null) { navigate = true; }
  if (app.request('require:loggedIn', path)) {
    if (navigate) { app.navigate(path, { metadata: { title } }); }
    if (app.request(`require:${accessLevel}:access`)) {
      return app.layout.main.show(new View(viewOptions));
    }
  }
};

const parseSearchResults = uri => (function(searchResults) {
  let uris = _.pluck(searchResults, 'uri');
  const prefix = uri.split(':')[0];
  if (prefix === 'wd') { uris = uris.filter(isntWdUri); }
  // Omit the current entity URI
  uris = _.without(uris, uri);
  // Search results entities miss their claims, so we need to fetch the full entities
  return app.request('get:entities:models', { uris });
});

var isntWdUri = uri => uri.split(':')[0] !== 'wd';

var isClaim = claim => /^(wdt:|invp:)/.test(claim);
var showClaimEntities = function(claim, refresh){
  const [ property, value ] = Array.from(claim.split('-'));

  if (!_.isPropertyUri(property)) {
    error_.report('invalid property');
    return app.execute('show:error:missing');
  }

  if (!_.isExtendedEntityUri(value)) {
    error_.report('invalid value');
    return app.execute('show:error:missing');
  }

  return app.layout.main.show(new ClaimLayout({ property, value, refresh }));
};

var reportTypeIssue = function(params){
  const { expectedType, model, context } = params;
  const [ uri, realType ] = Array.from(model.gets('uri', 'type'));
  if (reportedTypeIssueUris.includes(uri)) { return; }
  reportedTypeIssueUris.push(uri);

  const subject = `[Entity type] ${uri}: expected ${expectedType}, got ${realType}`;
  return app.request('post:feedback', { subject, uris: [ uri ], context });
};

var reportedTypeIssueUris = [];

var showEntityCleanupFromModel = function(entity){
  if (entity.type !== 'serie') {
    const err = error_.new(`cleanup isn't available for entity type ${type}`, 400);
    app.execute('show:error', err);
    return;
  }

  return entity.initSerieParts({ refresh: true, fetchAll: true })
  .then(function() {
    app.layout.main.show(new SerieCleanup({ model: entity }));
    return app.navigateFromModel(entity, 'cleanup');
  });
};
