unselectPlugin = require 'modules/inventory/plugins/unselect'
groupPlugin = require '../plugins/group'

module.exports = Marionette.ItemView.extend
  getTemplate: ->
    if @options.highlighted then require './templates/group_show'
    else require './templates/group'
  className: ->
    if @options.highlighted then 'groupShow'
    else 'group'
  tagName: -> if @options.highlighted then 'div' else 'li'
  initialize: ->
    @initPlugin()
    @lazyRender = _.debounce @render.bind(@), 200
    # using lazyRender instead of render allow to whait for group.mainUserStatus
    # to be ready (i.e. not to return 'none')
    @listenTo @model, 'change', @lazyRender

  initPlugin: ->
    unselectPlugin.call @
    groupPlugin.call @

  behaviors:
    PreventDefault: {}
    SuccessCheck: {}

  onShow: ->
    if @options.highlighted
      app.execute 'current:username:set', @model.get('name')

  onDestroy: ->
    if @options.highlighted
      app.execute 'current:username:hide'

  serializeData:->
    _.extend @model.serializeData(),
      highlighted: @options.highlighted
