groupPlugin = require 'modules/network/plugins/group'
SectionList = require './inventory_section_list'

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
      requestsCount: @model.get('requested').length

  onRender: ->
    @model.beforeShow()
    .then @ifViewIsIntact('showMembers')

  showMembers: ->
    @membersList.show new SectionList { collection: @model.members, context: 'group', group: @model }

  childEvents:
    select: (e, type, model)->
      app.vent.trigger 'inventory:select', 'member', model
