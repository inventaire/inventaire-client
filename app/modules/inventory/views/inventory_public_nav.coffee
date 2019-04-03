{ showUsersOnMap, showUserOnMap, showGroupsOnMap, getBbox } = require 'modules/map/lib/map'
{ solvePosition, drawMap } = require 'modules/network/lib/nearby_layouts'
{ currentRoute } = require 'lib/location'
Users = require 'modules/users/collections/users'
Groups = require 'modules/network/collections/groups'
InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryPublicNav'
  template: require './templates/inventory_public_nav'

  initialize: ->
    @collection = new Backbone.Collection
    @waitForAssets = app.request 'map:before'

  onShow: ->
    @showMap()

  showMap: ->
    path = 'inventory/public'
    Promise.all [ solvePosition(), @waitForAssets ]
    .spread (coords)=>
      showObjects = @showUsersAndGroupsNearby.bind @
      drawMap { showObjects, path }, coords

  showUsersAndGroupsNearby: (map)->
    bbox = getBbox map
    @showUsersByPosition map, bbox
    @showGroupsByPosition map, bbox

  showUsersByPosition: (map, bbox)->
    getByPosition 'users', Users, bbox
    .then (collection)=>
      showUsersOnMap map, collection.models
      showUserOnMap map, app.user
      @showList @usersList, collection

  showGroupsByPosition: (map, bbox)->
    getByPosition 'groups', Groups, bbox
    .then (collection)=>
      showGroupsOnMap map, collection.models
      @showList @groupsList, collection

getByPosition = (name, Collection, bbox)->
  _.preq.get app.API[name].searchByPosition(bbox)
  .get name
  .then (data)-> new Collection data
