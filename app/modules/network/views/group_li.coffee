groupPlugin = require '../plugins/group'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_li'
  className: 'groupLi'
  tagName: 'li'
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
