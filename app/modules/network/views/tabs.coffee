{ tabsData, resolveCurrentTab, getNameFromId } = require '../lib/network_tabs'

module.exports = Marionette.ItemView.extend
  template: require './templates/tabs'
  className: 'tabs'

  events:
    'click .tab': 'updateTabs'

  behaviors:
    PreventDefault: {}

  initialize: ->
    { tab } = @options
    @currentTab = tab
    @currentTabData = tabsData.all[tab]

    @lazyRender = _.LazyRender @

    # rerender once counter data arrived
    app.request 'waitForData'
    .then @lazyRender
    .then @listenToRequestsCollections.bind(@)

  updateTabs: (e)->
    unless _.isOpenedOutside e
      tab = getNameFromId e.currentTarget.id
      tab = resolveCurrentTab tab

      unless tab is @currentTab
        # triggering events on the parent view
        @triggerMethod 'tabs:change', tab
        @currentTab = tab
        @currentTabData = tabsData.all[tab]
        @render()

  serializeData: ->
    counters = app.request 'get:network:counters'

    { parent, name } = @currentTabData

    subTabsData = tabsData[parent]
    # The original object is edited
    # thus the need to reset active to false
    # Alternative: creating a new object clones every time
    # but it would be more expensive
    for k, v of subTabsData
      v.active = false
      { counter } = v
      if counter? then v.count = counters[counter]

    subTabsData[name].active = true

    data = _.extend counters,
      subTabsData: subTabsData

    data[parent] = true

    return data

  onRender: ->
    @updateMetadata()

  listenToRequestsCollections: ->
    @listenTo app.vent, 'network:requests:udpate', @lazyRender

  updateMetadata: ->
    { path, title } = @currentTabData
    navigate path
    updateTitle title

navigate = (path)->
  app.navigate path

updateTitle = (title)->
  title = _.I18n title
  network = _.I18n 'network'
  app.execute 'metadata:update:title', "#{title} - #{network}"
