{ showOnMap, getBbox } = require 'modules/map/lib/map'
{ initMap, grabMap, refreshListFilter } = require 'modules/network/lib/nearby_layouts'
{ currentRoute } = require 'lib/location'
Users = require 'modules/users/collections/users'
Groups = require 'modules/network/collections/groups'
InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryPublicNav'
  template: require './templates/inventory_public_nav'

  initialize: ->
    @users = new FilteredCollection(new Users)
    @groups = new FilteredCollection(new Groups)

  onShow: ->
    @initMap()
    @showList @usersList, @users
    @showList @groupsList, @groups

  initMap: ->
    initMap
      view: @
      query: @options.query
      path: 'inventory/public'
      showObjects: @fetchAndShowUsersAndGroupsOnMap.bind(@)
      onMoveend: @onMovend.bind(@)
    .then grabMap.bind(@)
    .catch _.Error('initMap')

  fetchAndShowUsersAndGroupsOnMap: (map)->
    bbox = getBbox map
    @showByPosition 'users', bbox
    @showByPosition 'groups', bbox

  showByPosition: (name, bbox)->
    getByPosition @[name]._superset, name, bbox
    .then => showOnMap name, @map, @[name].models

  onMovend: ->
    refreshListFilter.call @, @users, @map
    refreshListFilter.call @, @groups, @map
    @fetchAndShowUsersAndGroupsOnMap @map

getByPosition = (collection, name, bbox)->
  _.preq.get app.API[name].searchByPosition(bbox)
  .get name
  .then collection.add.bind(collection)
