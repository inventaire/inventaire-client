import ItemShow from './views/item_show';
import initQueries from './lib/queries';
import InventoryLayout from './views/inventory_layout';
import initLayout from './lib/layout';
import ItemsCascade from './views/items_cascade';
import showItemCreationForm from './lib/show_item_creation_form';
import itemActions from './lib/item_actions';
import { parseQuery, currentRoute, buildPath } from 'lib/location';
import error_ from 'lib/error';

export default {
  define(module, app, Backbone, Marionette, $, _){
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'inventory(/)': 'showGeneralInventory',
        'inventory/network(/)': 'showNetworkInventory',
        'inventory/public(/)': 'showPublicInventory',
        'inventory/nearby(/)': 'showInventoryNearby',
        'inventory/last(/)': 'showInventoryLast',
        'inventory/:username(/)': 'showUserInventoryFromUrl',
        // 'title' is a legacy parameter
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity',
        'items/:id(/)': 'showItemFromId',
        'items(/)': 'showGeneralInventory',
        // 'name' is a legacy parameter
        'g(roups)/:id(/:name)(/)': 'showGroupInventory'
      }
    });

    return app.addInitializer(() => new Router({ controller: API }));
  },

  initialize() {
    initQueries(app);
    initializeInventoriesHandlers(app);
    return initLayout(app);
  }
};

var API = {
  showGeneralInventory() {
    if (app.request('require:loggedIn', 'inventory')) {
      API.showUserInventory(app.user);
      // Give focus to the home button so that hitting tab gives focus
      // to the search input
      return $('#home').focus();
    }
  },

  showNetworkInventory() {
    if (app.request('require:loggedIn', 'inventory/network')) {
      showInventory({ section: 'network' });
      return app.navigate('inventory/network');
    }
  },

  showPublicInventory(options = {}){
    if (_.isString(options)) { options = parseQuery(options); }
    const { filter } = options;
    const url = buildPath('inventory/public', { filter });

    if (app.request('require:loggedIn', url)) {
      showInventory({ section: 'public', filter });
      return app.navigate(url);
    }
  },

  showUserInventory(user, standalone){
    return showInventory({ user, standalone });
  },

  showUserInventoryFromUrl(username){
    return showInventory({ user: username, standalone: true });
  },

  showGroupInventory(group, standalone = true){
    return showInventory({ group, standalone });
  },

  showInventoryNearby() {
    if (app.request('require:loggedIn', 'inventory/nearby')) {
      return showInventory({ nearby: true });
    }
  },

  showInventoryLast() {
    if (app.request('require:loggedIn', 'inventory/last')) {
      return showInventory({ last: true });
    }
  },

  showItemFromId(id){
    if (!_.isItemId(id)) { return app.execute('show:error:missing'); }

    return app.request('get:item:model', id)
    .then(app.Execute('show:item'))
    .catch(err => app.execute('show:error', err, 'showItemFromId'));
  },

  showUserItemsByEntity(username, uri, label){
    if (!_.isUsername(username) || !_.isEntityUri(uri)) {
      return app.execute('show:error:missing');
    }

    const title = label ? `${label} - ${username}` : `${uri} - ${username}`;

    app.execute('show:loader');
    app.navigate(`/inventory/${username}/${uri}`, { metadata: { title } });

    return app.request('get:userId:from:username', username)
    .then(userId => app.request('items:getByUserIdAndEntities', userId, uri))
    .then(showItemsFromModels)
    .catch(_.Error('showItemShowFromUserAndEntity'));
  }
};

var showItemsFromModels = function(items){
  // Accept either an items collection or an array of items models
  if (_.isArray(items)) { items = new Backbone.Collection(items); }

  if (items?.length == null) {
    throw new Error('shouldnt be at least an empty array here?');
  }

  switch (items.length) {
    case 0: return app.execute('show:error:missing');
    // redirect to the item
    case 1:
      var item = items.models[0];
      var fallback = () => API.showUserInventory(item.get('owner'), true);
      return showItemModal(item, fallback);
    default: return showItemsList(items);
  }
};

var showInventory = options => app.layout.main.show(new InventoryLayout(options));

var showItemsList = collection => app.layout.main.show(new ItemsCascade({ collection }));

var showItemModal = function(model, fallback){
  _.type(model, 'object');

  const previousRoute = currentRoute();
  // Do not scroll top as the modal might be displayed down at the level
  // where the item show event was triggered
  app.navigateFromModel(model, { preventScrollTop: true });
  const newRoute = currentRoute();

  const navigateAfterModal = function() {
    if (currentRoute() !== newRoute) { return; }
    if (previousRoute === newRoute) {
      return app.execute('show:inventory:user', model.get('owner'));
    }
    return app.navigate(previousRoute, { preventScrollTop: true });
  };

  if (!fallback) { fallback = navigateAfterModal; }

  // Let the time to other callbacks to call a navigation before testing if the route
  // should be recovered
  app.vent.once('modal:closed', () => setTimeout(fallback, 10));

  return model.grabWorks()
  .then(() => app.layout.modal.show(new ItemShow({ model })))
  .catch(app.Execute('show:error'));
};

var initializeInventoriesHandlers = function(app){
  app.commands.setHandlers({
    'show:inventory': showInventory,
    'show:inventory:section'(section){
      switch (section) {
        case 'user': return API.showUserInventory(app.user);
        case 'network': return API.showNetworkInventory();
        case 'public': return API.showPublicInventory();
        default: throw error_.new('unknown section', 400, { section });
      }
    },

    'show:inventory:network': API.showNetworkInventory,
    'show:inventory:public': API.showPublicInventory,

    'show:users:nearby'() { return API.showPublicInventory({ filter: 'users' }); },
    'show:groups:nearby'() { return API.showPublicInventory({ filter: 'groups' }); },

    // user can be either a username or a user model
    'show:inventory:user'(user){
      return API.showUserInventory(user, true);
    },

    'show:inventory:main:user'() {
      return API.showUserInventory(app.user, true);
    },

    'show:inventory:group': API.showGroupInventory,

    'show:inventory:group:byId'(params){
      const { groupId, standalone } = params;
      return app.request('get:group:model', groupId)
      .then(group => API.showGroupInventory(group, standalone))
      .catch(app.Execute('show:error'));
    },

    'show:item:creation:form': showItemCreationForm,

    'show:item': showItemModal,
    'show:item:byId': API.showItemFromId,

    'show:inventory:nearby': API.showInventoryNearby,
    'show:inventory:last': API.showInventoryLast
  });

  return app.reqres.setHandlers({
    'items:update': itemActions.update,
    'items:delete': itemActions.delete,
    'item:create': itemActions.create,
    'item:main:user:entity:items'(entityUri){
      return app.request('items:getByUserIdAndEntities', app.user.id, entityUri)
      .get('models');
    },
    'item:update:entity'(item, entity){
      return itemActions.update({
        item,
        attribute: 'entity',
        value: entity.get('uri')}).delay(500)
      // before requesting an updated item
      .then(() => app.request('get:item:model', item.get('_id')))
      .then(updatedItem => app.execute('show:item', updatedItem));
    }
  });
};
