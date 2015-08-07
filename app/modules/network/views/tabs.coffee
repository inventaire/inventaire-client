module.exports = Marionette.ItemView.extend
  template: require './templates/tabs'
  className: 'tabs'

  ui:
    tabs: '.tab'
    friendsTab: '#friendsTab'
    groupsTab: '#groupsTab'

  initialize: ->
    @lazyRender = _.debounce @render.bind(@), 200

    app.request('waitForData')
    .then @lazyRender
    .then @listenToRequestsCollections.bind(@)

  onRender: ->
    { tab } = @options
    @ui.tabs.removeClass 'active'
    @ui["#{tab}Tab"].addClass 'active'

  serializeData: -> @getNetworkCounters()

  getNetworkCounters: -> app.request 'get:network:counters'

  listenToRequestsCollections: ->
    @listenTo app.users.otherRequested, 'add remove', @lazyRender
    @listenTo app.user.groups.mainUserInvited, 'add remove', @lazyRender
