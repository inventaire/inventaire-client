tabsData = require 'modules/inventory/lib/add_layout_tabs'

module.exports = Marionette.LayoutView.extend
  template: require './templates/add_layout'
  id: 'addLayout'

  regions:
    content: '.custom-tabs-content'

  ui:
    tabs: '.tab'
    searchTab: '#searchTab'
    scanTab: '#scanTab'
    importTab: '#importTab'

  initialize: ->
    @loggedIn = app.user.loggedIn

  serializeData: ->
    loggedIn: @loggedIn
    tabs: tabsData

  behaviors:
    PreventDefault: {}

  events:
    'click .tab': 'changeTab'

  onShow: ->
    if @loggedIn
      @showTabView @options.tab
    else
      msg = 'you need to be connected to add a book to your inventory'
      app.execute 'show:call:to:connection', msg

  onDestroy: ->
    unless @loggedIn
      app.execute 'modal:close'

  showTabView: (tab)->
    View = require "./#{tab}"
    @content.show new View @options
    tabKey = "#{tab}Tab"
    @ui.tabs.removeClass 'active'
    @ui[tabKey].addClass 'active'
    app.navigate "add/#{tab}"

  changeTab: (e)->
    tab = e.currentTarget.id.split('Tab')[0]
    @showTabView tab
    if _.smallScreen() then _.scrollTop @content.$el
