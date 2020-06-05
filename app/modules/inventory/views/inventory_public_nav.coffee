{ showOnMap, showUserOnMap, getBbox } = require 'modules/map/lib/map'
{ initMap, grabMap, refreshListFilter } = require 'modules/network/lib/nearby_layouts'
{ currentRoute } = require 'lib/location'
Users = require 'modules/users/collections/users'
Groups = require 'modules/network/collections/groups'
InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = InventoryCommonNav.extend
  id: 'inventoryPublicNav'
  template: require './templates/inventory_public_nav'

  initialize: ->
    { @filter } = @options

    if @filter?
      if @filter is 'users' then @hideGroups = true
      else if @filter is 'groups' then @hideUsers = true

    @users = new FilteredCollection(new Users)
    @groups = new FilteredCollection(new Groups)

    # Listen for the server confirmation instead of simply the change
    # so that 'nearby' request aren't done while the server
    # is still editing the user's position and might thus return a 400
    @listenTo app.user, 'confirmed:position', @lazyRender.bind(@)

  behaviors:
    Loading: {}

  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'
    'click .userMarker a': 'showUser'
    'click .groupMarker a': 'showGroup'

  serializeData: ->
    mainUserHasPosition: app.user.get('position')?
    hideUsers: @hideUsers
    hideGroups: @hideGroups

  onRender: ->
    if app.user.get('position')?
      @initMap()
      unless @hideUsers then @showList @usersList, @users
      unless @hideGroups then @showList @groupsList, @groups

  initMap: ->
    initMap
      view: @
      query: @options.query
      path: 'inventory/public'
      showObjects: @fetchAndShowUsersAndGroupsOnMap.bind(@)
      onMoveend: @onMovend.bind(@)
      updateRoute: false
    .then grabMap.bind(@)
    .catch _.Error('initMap')

  fetchAndShowUsersAndGroupsOnMap: (map)->
    displayedElementsCount = @users.length + @groups.length
    if map._zoom < 10 and displayedElementsCount > 20 then return
    bbox = getBbox map

    unless @hideUsers
      showUserOnMap map, app.user
      @showByPosition 'users', bbox

    unless @hideGroups
      @showByPosition 'groups', bbox

  showByPosition: (name, bbox)->
    startLoading.call @, ".#{name}Loading"
    getByPosition @[name]._superset, name, bbox
    .then =>
      showOnMap name, @map, @[name].models
      stopLoading.call @, ".#{name}Loading"

  onMovend: ->
    unless @hideUsers then refreshListFilter.call @, @users, @map
    unless @hideGroups then refreshListFilter.call @, @groups, @map
    @fetchAndShowUsersAndGroupsOnMap @map

  showUser: (e)->
    if _.isOpenedOutside e then return
    userId = e.currentTarget.attributes['data-user-id'].value
    app.request 'resolve:to:userModel', userId
    .then (user)-> app.vent.trigger 'inventory:select', 'user', user

  showGroup: (e)->
    if _.isOpenedOutside e then return
    groupId = e.currentTarget.attributes['data-group-id'].value
    app.request 'resolve:to:groupModel', groupId
    .then (group)-> app.vent.trigger 'inventory:select', 'group', group

getByPosition = (collection, name, bbox)->
  _.preq.get app.API[name].searchByPosition(bbox)
  .get name
  .then (docs)->
    filter = filters[name]
    if filter? then docs = docs.filter filter
    return collection.add docs

filters =
  # Filter-out main user
  users: (doc)-> doc._id isnt app.user.id
