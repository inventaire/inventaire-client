{ showUsersOnMap, showUserOnMap, updateMarker, getBbox } = require 'modules/map/lib/map'
{ path } = require('../lib/network_tabs').tabsData.users.nearbyUsers
UsersList = require 'modules/users/views/users_list'
{ initMap, regions, grabMap, refreshListFilter } = require '../lib/nearby_layouts'

module.exports = Marionette.LayoutView.extend
  template: require './templates/nearby_users_layout'
  id: 'nearbyUsersLayout'
  regions: regions
  behaviors:
    PreventDefault: {}
    Loading: {}

  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'

  initMap: ->
    initMap
      view: @
      query: @options.query
      path: path
      showObjects: @showUsersNearby.bind(@)
      onMoveend: @onMovend.bind(@)
    .then grabMap.bind(@)
    .then @initList.bind(@)
    .catch _.Error('initMap')

  initialize: ->
    @collection = app.users.filtered.resetFilters()
    @listenTo app.user, 'change:position', @updateMainUserPosition.bind(@)
    @lazyInitMap = _.debounce @initMap.bind(@), 300

  onRender: ->
    app.request 'waitForNetwork'
    # render might be called several times
    .then @lazyInitMap.bind(@)

  serializeData: ->
    hasPosition: app.user.hasPosition()

  onMovend: ->
    refreshListFilter.call @
    @showUsersNearby @map

  # showUsersNearby might be used before grabMap
  # thus the need to explicitly pass the map
  showUsersNearby: (map)->
    app.request 'users:search:byPosition', getBbox(map)
    .then @updateUsersMarkers.bind(@)

  updateUsersMarkers: ->
    showUsersOnMap @map, @collection.models
    @mainUserMarker = showUserOnMap @map, app.user

  initList: ->
    @list.show new UsersList
      collection: @collection
      stretch: true
      emptyViewMessage: "can't find any user at this location"
      # avoid showing the main user in the list
      filter: (model)-> model.id isnt app.user.id

    refreshListFilter.call @

  updateMainUserPosition: ->
    if @mainUserMarker?
      updateMarker @mainUserMarker, app.user.getCoords()
