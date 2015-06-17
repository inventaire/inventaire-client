module.exports = Marionette.ItemView.extend
  template: require './templates/icon_nav'
  className: 'innerIconNav'
  initialize: ->
    @lazyRender = _.debounce @render.bind(@), 200
  events:
    'click .add': 'showAddLayout'
    'click .exchanges': 'showTransactions'
    'click .browse': 'showInventory'

  ui:
    all: 'a.iconButton'
    add: '.add'
    exchanges: '.exchanges'
    browse: '.browse'

  serializeData: ->
    exchangesUpdates: @exchangesUpdates()

  onShow: ->
    @selectButtonFromRoute _.currentSection()
    @listenTo app.vent, 'route:navigate', @selectButtonFromRoute.bind(@)
    @listenTo app.vent, 'transactions:unread:change', @lazyRender

  selectButtonFromRoute: (section)->
    @unselectAll()
    switch section
      when 'add' then @selectButton 'add'
      when 'transactions' then @selectButton 'exchanges'
      when 'inventory' then @selectButton 'browse'

  unselectAll: ->
    @ui.all.removeClass 'selected'

  selectButton: (uiName)->
    @ui[uiName].addClass 'selected'

  showAddLayout: ->
    @selectButton 'add'
    app.execute 'show:add:layout'

  showTransactions: ->
    @selectButton 'exchanges'
    app.execute 'show:transactions'

  showInventory: ->
    @selectButton 'browse'
    app.execute 'show:inventory:general'

  exchangesUpdates: ->
    app.request 'transactions:unread:count'
