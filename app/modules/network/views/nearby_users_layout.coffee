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
    'click .userIcon a': 'showUser'

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
    .then @ifViewIsIntact('lazyInitMap')

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
    # Always load the main user marker, so that if it changes position,
    # it can be updated to eventually be shown in the current map frame
    showUserOnMap @map, app.user
    { @mainUserMarker } = @map

  showUser: (e)->
    unless _.isOpenedOutside e
      id = e.currentTarget.attributes['data-user-id'].value
      app.execute 'show:inventory:user', id

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
