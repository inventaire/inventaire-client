module.exports = Marionette.ItemView.extend
  template: require './templates/icon_nav'
  className: 'innerIconNav'
  initialize: ->
    @lazyRender = _.LazyRender @
    @once 'render', @initListeners.bind(@)

  initListeners: ->
    @listenTo app.vent, 'route:change', @selectButtonFromRoute.bind(@)
    @listenTo app.vent, 'transactions:unread:change', @lazyRender
    @listenTo app.vent, 'i18n:reset', @lazyRender
    @listenTo app.vent, 'network:requests:udpate', @lazyRender

  events:
    'click .add': 'showAddLayout'
    'click .network': 'showNetwork'
    'click .browse': 'showInventory'
    'click .map': 'showMap'
    'click .exchanges': 'showTransactions'

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
    @unselectAll()
    switch section
      when 'add', 'search' then @selectButton 'add'
      when 'network' then @selectButton 'network'
      when 'inventory', 'groups' then @selectButton 'browse'
      when 'map' then @selectButton 'map'
      when 'transactions' then @selectButton 'exchanges'

    # sections without an associated icon nav button:
    # entity, settings

  unselectAll: ->
    @ui.all.removeClass 'selected'

  selectButton: (uiName)->
    @ui[uiName].addClass 'selected'

  showAddLayout: (e)->
    unless _.isOpenedOutside e
      @selectButton 'add'
      app.execute 'show:add:layout'

  showNetwork: (e)->
    unless _.isOpenedOutside e
      @selectButton 'network'
      app.execute 'show:network'

  showInventory: (e)->
    unless _.isOpenedOutside e
      @selectButton 'browse'
      app.execute 'show:inventory:general'

  showMap: (e)->
    unless _.isOpenedOutside e
      @selectButton 'map'
      app.execute 'show:map'

  showTransactions: (e)->
    unless _.isOpenedOutside e
      @selectButton 'exchanges'
      app.execute 'show:transactions'

  networkUpdates: ->
    app.request('get:network:counters').total

  exchangesUpdates: ->
    app.request 'transactions:unread:count'
