{ GroupItemView } = require './group_views_commons'

module.exports = GroupItemView.extend
  template: require './templates/group_board_header'
  className: 'group-board-header'

  modelEvents:
    'change': 'lazyRender'

  behaviors:
    PreventDefault: {}

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return { username }
