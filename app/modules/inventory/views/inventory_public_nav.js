import { showOnMap, showUserOnMap, getBbox } from 'modules/map/lib/map';
import { initMap, grabMap, refreshListFilter } from 'modules/network/lib/nearby_layouts';
import { currentRoute } from 'lib/location';
import Users from 'modules/users/collections/users';
import Groups from 'modules/network/collections/groups';
import InventoryCommonNav from 'modules/inventory/views/inventory_common_nav';
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors';

export default InventoryCommonNav.extend({
  id: 'inventoryPublicNav',
  template: require('./templates/inventory_public_nav'),

  initialize() {
    ({ filter: this.filter } = this.options);

    if (this.filter != null) {
      if (this.filter === 'users') { this.hideGroups = true;
      } else if (this.filter === 'groups') { this.hideUsers = true; }
    }

    this.users = new FilteredCollection(new Users);
    this.groups = new FilteredCollection(new Groups);

    // Listen for the server confirmation instead of simply the change
    // so that 'nearby' request aren't done while the server
    // is still editing the user's position and might thus return a 400
    return this.listenTo(app.user, 'confirmed:position', this.lazyRender.bind(this));
  },

  behaviors: {
    Loading: {}
  },

  events: {
    'click #showPositionPicker'() { return app.execute('show:position:picker:main:user'); },
    'click .userMarker a': 'showUser',
    'click .groupMarker a': 'showGroup'
  },

  serializeData() {
    return {
      mainUserHasPosition: (app.user.get('position') != null),
      hideUsers: this.hideUsers,
      hideGroups: this.hideGroups
    };
  },

  onRender() {
    if (app.user.get('position') != null) {
      this.initMap();
      if (!this.hideUsers) { this.showList(this.usersList, this.users); }
      if (!this.hideGroups) { return this.showList(this.groupsList, this.groups); }
    }
  },

  initMap() {
    return initMap({
      view: this,
      query: this.options.query,
      path: 'inventory/public',
      showObjects: this.fetchAndShowUsersAndGroupsOnMap.bind(this),
      onMoveend: this.onMovend.bind(this),
      updateRoute: false}).then(grabMap.bind(this))
    .catch(_.Error('initMap'));
  },

  fetchAndShowUsersAndGroupsOnMap(map){
    const displayedElementsCount = this.users.length + this.groups.length;
    if ((map._zoom < 10) && (displayedElementsCount > 20)) { return; }
    const bbox = getBbox(map);

    if (!this.hideUsers) {
      showUserOnMap(map, app.user);
      this.showByPosition('users', bbox);
    }

    if (!this.hideGroups) {
      return this.showByPosition('groups', bbox);
    }
  },

  showByPosition(name, bbox){
    startLoading.call(this, `.${name}Loading`);
    return getByPosition(this[name]._superset, name, bbox)
    .then(() => {
      showOnMap(name, this.map, this[name].models);
      return stopLoading.call(this, `.${name}Loading`);
    });
  },

  onMovend() {
    if (!this.hideUsers) { refreshListFilter.call(this, this.users, this.map); }
    if (!this.hideGroups) { refreshListFilter.call(this, this.groups, this.map); }
    return this.fetchAndShowUsersAndGroupsOnMap(this.map);
  },

  showUser(e){
    if (_.isOpenedOutside(e)) { return; }
    const userId = e.currentTarget.attributes['data-user-id'].value;
    return app.request('resolve:to:userModel', userId)
    .then(user => app.vent.trigger('inventory:select', 'user', user));
  },

  showGroup(e){
    if (_.isOpenedOutside(e)) { return; }
    const groupId = e.currentTarget.attributes['data-group-id'].value;
    return app.request('resolve:to:groupModel', groupId)
    .then(group => app.vent.trigger('inventory:select', 'group', group));
  }
});

var getByPosition = (collection, name, bbox) => _.preq.get(app.API[name].searchByPosition(bbox))
.get(name)
.then(function(docs){
  const filter = filters[name];
  if (filter != null) { docs = docs.filter(filter); }
  return collection.add(docs);
});

var filters =
  // Filter-out main user
  {users(doc){ return doc._id !== app.user.id; }};
