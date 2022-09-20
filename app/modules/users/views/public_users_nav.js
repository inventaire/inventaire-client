import FilteredCollection from 'backbone-filtered-collection'
import log_ from '#lib/loggers'
import { isOpenedOutside } from '#lib/utils'
import preq from '#lib/preq'
import map_ from '#map/lib/map'
import { initMap, grabMap, refreshListFilter } from '#network/lib/nearby_layouts'
import Users from '#users/collections/users'
import Groups from '#groups/collections/groups'
import InventoryCommonNav from '#users/views/users_home_sections_common_nav'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import publicUsersNavTemplate from './templates/public_users_nav.hbs'
import '#map/scss/position_required.scss'
import Loading from '#behaviors/loading'

const { showOnMap, showUserOnMap, getBbox, isValidBbox } = map_

export default InventoryCommonNav.extend({
  id: 'publicUsersNav',
  template: publicUsersNavTemplate,

  initialize () {
    const { filter } = this.options

    if (filter != null) {
      if (filter === 'users') this.hideGroups = true
      else if (filter === 'groups') this.hideUsers = true
    }

    this.users = new FilteredCollection(new Users())
    this.groups = new FilteredCollection(new Groups())

    // Listen for the server confirmation instead of simply the change
    // so that 'nearby' request aren't done while the server
    // is still editing the user's position and might thus return a 400
    this.listenTo(app.user, 'confirmed:position', this.lazyRender.bind(this))
  },

  behaviors: {
    Loading,
  },

  events: {
    'click #showPositionPicker' () { app.execute('show:position:picker:main:user') },
    'click .userMarker a': 'showUser',
    'click .groupMarker a': 'showGroup'
  },

  serializeData () {
    return {
      mainUserHasPosition: (app.user.get('position') != null),
      hideUsers: this.hideUsers,
      hideGroups: this.hideGroups
    }
  },

  onRender () {
    if (app.user.get('position') != null) {
      this.initMap()
      if (!this.hideUsers) this.showList('usersList', this.users)
      if (!this.hideGroups) this.showList('groupsList', this.groups)
    }
  },

  initMap () {
    return initMap({
      view: this,
      query: this.options.query,
      path: 'inventory/public',
      showObjects: this.fetchAndShowUsersAndGroupsOnMap.bind(this),
      onMoveend: this.onMovend.bind(this),
      updateRoute: false
    })
    .then(grabMap.bind(this))
    .catch(log_.Error('initMap'))
  },

  fetchAndShowUsersAndGroupsOnMap (map) {
    const displayedElementsCount = this.users.length + this.groups.length
    if ((map._zoom < 10) && (displayedElementsCount > 20)) return
    const bbox = getBbox(map)

    if (!this.hideUsers) {
      showUserOnMap(map, app.user)
      this.showByPosition('users', bbox)
    }

    if (!this.hideGroups) {
      this.showByPosition('groups', bbox)
    }
  },

  async showByPosition (name, bbox) {
    startLoading.call(this, `.${name}Loading`)
    await getByPosition(this[name]._superset, name, bbox)
    showOnMap(name, this.map, this[name].models)
    stopLoading.call(this, `.${name}Loading`)
  },

  onMovend () {
    if (!this.hideUsers) refreshListFilter.call(this, this.users, this.map)
    if (!this.hideGroups) refreshListFilter.call(this, this.groups, this.map)
    this.fetchAndShowUsersAndGroupsOnMap(this.map)
  },

  showUser (e) {
    if (isOpenedOutside(e)) return
    const userId = e.currentTarget.attributes['data-user-id'].value
    return app.request('resolve:to:userModel', userId)
    .then(user => app.vent.trigger('inventory:select', 'user', user))
  },

  showGroup (e) {
    if (isOpenedOutside(e)) return
    const groupId = e.currentTarget.attributes['data-group-id'].value
    return app.request('resolve:to:groupModel', groupId)
    .then(group => app.vent.trigger('inventory:select', 'group', group))
  }
})

const getByPosition = async (collection, name, bbox) => {
  if (!isValidBbox(bbox)) return
  const res = await preq.get(app.API[name].searchByPosition(bbox))
  let docs = res[name]
  const filter = filters[name]
  if (filter != null) docs = docs.filter(filter)
  return collection.add(docs)
}

const filters = {
  // Filter-out main user
  users: doc => doc._id !== app.user.id
}