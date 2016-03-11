module.exports = Marionette.ItemView.extend
  template: require './templates/icon_nav'
  className: 'innerIconNav'
  initialize: ->
    @lazyRender = _.LazyRender @
    @once 'render', @initListeners.bind(@)

  initListeners: ->
    @listenTo app.vent,
      'route:change': @selectButtonFromRoute.bind(@)
      'transactions:unread:change': @lazyRender
      'i18n:reset': @lazyRender
      'network:requests:udpate': @lazyRender

  events:
    'click .iconButton': 'showLayout'

  ui:
    all: 'a.iconButton'
    add: '.add'
    network: '.network'
    browse: '.browse'
    map: '.map'
    exchanges: '.exchanges'

  behaviors:
    PreventDefault: {}

  serializeData: ->
    networkUpdates: @networkUpdates()
    exchangesUpdates: @exchangesUpdates()

  onRender: ->
    @selectButtonFromRoute _.currentSection()

  selectButtonFromRoute: (section)->
    if _.isNonEmptyString(section) and section isnt lastSection
      @unselectAll()
      button = sectionsButtonMap[section]
      # some sections don't have an associated button
      # so we just unselect the current one
      if button? then @selectButton
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

  networkUpdates: ->
    app.request('get:network:counters').total

  exchangesUpdates: ->
    app.request 'transactions:unread:count'

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

commands =
  add: 'show:add:layout'
  network: 'show:network'
  browse: 'show:inventory:general'
  exchanges: 'show:transactions'
