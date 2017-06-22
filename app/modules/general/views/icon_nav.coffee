module.exports = Marionette.ItemView.extend
  template: require './templates/icon_nav'
  className: 'innerIconNav'
  initialize: ->
    @lazyRender = _.LazyRender @
    @once 'render', @initListeners.bind(@)

    # Re-render once app.relations is populated to display network counters
    app.request('wait:for', 'user').then @lazyRender

  initListeners: ->
    @listenTo app.vent,
      'screen:mode:change': @lazyRender
      'route:change': @selectButtonFromRoute.bind(@)
      'transactions:unread:change': @lazyRender
      'network:requests:update': @lazyRender

  events:
    'click .iconButton': 'showLayout'

  ui:
    all: 'a.iconButton'
    add: '.add'
    network: '.network'
    browse: '.browse'
    map: '.map'
    exchanges: '.exchanges'
    settings: '.settings'
    notifications: '.notifications'

  behaviors:
    PreventDefault: {}

  serializeData: ->
    networkUpdates: @networkUpdates()
    exchangesUpdates: @exchangesUpdates()
    notificationsUpdates: @notificationsUpdates()
    smallScreen: _.smallScreen()
    isLoggedIn: app.user.loggedIn

  onRender: ->
    @selectButtonFromRoute _.currentSection()

  selectButtonFromRoute: (section)->
    if _.isNonEmptyString(section) and section isnt lastSection
      @unselectAll()
      button = sectionsButtonMap[section]
      # some sections don't have an associated button
      # so we just unselect the current one
      if button? then @selectButton button
      lastSection = section

  unselectAll: -> @ui.all.removeClass 'selected'
  selectButton: (uiName)-> @ui[uiName].addClass 'selected'

  # no need to manually add and remove the 'selected' class
  # as the command should trigger a route change
  # which in turn will fire @selectButtonFromRoute
  showLayout: (e)->
    unless _.isOpenedOutside e
      commandKey = e.currentTarget.id.split('IconButton')[0]
      app.execute commands[commandKey]
      # Update notifications count
      if commandKey is 'notifications' then @lazyRender()

  networkUpdates: ->
    if app.relations? then app.request('get:network:counters').total

  exchangesUpdates: -> app.request 'transactions:unread:count'

  notificationsUpdates: -> app.request 'notifications:unread:count'

lastSection = null

# sections without an associated icon nav button:
# entity, settings
sectionsButtonMap =
  add: 'add'
  search: 'add'
  network: 'network'
  inventory: 'browse'
  groups: 'browse'
  transactions: 'exchanges'
  settings: 'settings'
  notifications: 'notifications'

commands =
  add: 'show:add:layout'
  network: 'show:network'
  browse: 'show:inventory:general'
  exchanges: 'show:transactions'
  settings: 'show:settings:menu'
  notifications: 'show:notifications'
