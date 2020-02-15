{ GroupItemView } = require './group_views_commons'

module.exports = GroupItemView.extend
  template: require './templates/group_li'
  className: 'groupLi'
  tagName: 'li'
  initialize: ->
    @lazyRender = _.LazyRender @
    # using lazyRender instead of render allow to wait for group.mainUserStatus
    # to be ready (i.e. not to return 'none')
    @listenTo @model, 'change', @lazyRender

  behaviors:
    PreventDefault: {}
    SuccessCheck: {}
