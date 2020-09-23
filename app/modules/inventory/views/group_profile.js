SectionList = require './inventory_section_list'
{ GroupLayoutView } = require 'modules/network/views/group_views_commons'

module.exports = GroupLayoutView.extend
  template: require './templates/group_profile'
  className: 'groupProfile'

  regions:
    membersList: '#membersList'

  modelEvents:
    # using lazyRender instead of render allow to wait for group.mainUserStatus
    # to be ready (i.e. not to return 'none')
    'change': 'lazyRender'

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
