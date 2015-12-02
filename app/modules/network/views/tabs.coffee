{ tabsData, resolveCurrentTab } = require '../lib/network_tabs'

module.exports = Marionette.ItemView.extend
  template: require './templates/tabs'
  className: 'tabs'

  ui:
    tabs: '.tab'

    usersTab: '#usersTab'
    friendsTab: '#friendsTab'
    allUsersTab: '#allUsersTab'
    usersLevel2: '.users-level-2'
    groupsTab: '#groupsTab'
    userGroupsTab: '#userGroupsTab'
    allGroupsTab: '#allGroupsTab'
    groupsLevel2: '.groups-level-2'
    level2: '.level-2'

  events:
    'click .tab': 'updateTabs'

  initialize: ->
    { tab } = @options
    @currentTab = tab
    @currentTabData = tabsData[tab]

    @lazyRender = _.LazyRender @

    # rerender once counter data arrived
    app.request 'waitForData'
    .then @lazyRender
    .then @listenToRequestsCollections.bind(@)

  updateTabs: (e)->
    tab = e.currentTarget.id.replace 'Tab', ''
    tab = resolveCurrentTab tab

    unless tab is @currentTab
      # triggering events on the parent view
      @triggerMethod 'tabs:change', tab
      @currentTab = tab
      @currentTabData = tabsData[tab]
      @render()

  serializeData: ->
    networkCoutner = app.request 'get:network:counters'
    _.extend @getTabData(), networkCoutner

  getTabData: ->
    { parent, section } = @currentTabData
    tabData = {}
    tabData[parent] = true
    tabData[section] = true
    return tabData

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
