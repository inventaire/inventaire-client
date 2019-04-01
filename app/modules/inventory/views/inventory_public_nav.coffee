{ showUsersOnMap, showUserOnMap, showGroupsOnMap, getBbox } = require 'modules/map/lib/map'
{ solvePosition, drawMap } = require 'modules/network/lib/nearby_layouts'
{ currentRoute } = require 'lib/location'
User = require 'modules/users/models/user'
Group = require 'modules/network/models/group'

module.exports = Marionette.LayoutView.extend
  id: 'inventoryPublicNav'
  template: require './templates/inventory_public_nav'

  initialize: ->
    @collection = new Backbone.Collection
    @waitForAssets = app.request 'map:before'

  onShow: ->
    @showMap()

  showMap: ->
    path = currentRoute()
    Promise.all [ solvePosition(), @waitForAssets ]
    .spread (coords)=>
      showObjects = @showUsersAndGroupsNearby.bind @
      drawMap { showObjects, path }, coords

  showUsersAndGroupsNearby: (map)->
    bbox = getBbox map
    @showUsersByPosition map, bbox
    @showGroupsByPosition map, bbox

  showUsersByPosition: (map, bbox)->
    getByPosition 'users', User, bbox
    .then (models)->
      showUsersOnMap map, models
      showUserOnMap map, app.user

  showGroupsByPosition: (map, bbox)->
    getByPosition 'groups', Group, bbox
    .then (models)-> showGroupsOnMap map, models

getByPosition = (name, Model, bbox)->
  _.preq.get app.API[name].searchByPosition(bbox)
  .get name
  .map (data)-> new Model data
