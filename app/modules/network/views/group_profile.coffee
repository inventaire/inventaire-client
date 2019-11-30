groupPlugin = require '../plugins/group'
List = require 'modules/inventory/views/inventory_network_nav_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_profile'
  className: 'groupProfile'

  regions:
    membersList: '#membersList'

  initialize: ->
    @initPlugin()
    @lazyRender = _.LazyRender @
    # using lazyRender instead of render allow to wait for group.mainUserStatus
    # to be ready (i.e. not to return 'none')
    @listenTo @model, 'change', @lazyRender

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}
    SuccessCheck: {}

  serializeData:->
    _.extend @model.serializeData(),
      highlighted: @options.highlighted
      rss: @model.getRss()

  onShow: ->
    @model.beforeShow()
    .then @ifViewIsIntact('showMembers')

  showMembers: -> @membersList.show new List { collection: @model.members }

  childEvents:
    select: (e, type, model)->
      app.vent.trigger 'inventory:select:member', model
