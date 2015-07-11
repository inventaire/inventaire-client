unselectPlugin = require 'modules/inventory/plugins/unselect'
groupPlugin = require '../plugins/group'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  getTemplate: ->
    if @options.highlighted then require './templates/group_show'
    else require './templates/group'
  className: 'group'
  tagName: 'li'
  initialize: ->
    @initPlugin()

    @listenTo @model, 'change', @render.bind(@)

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

  events:
    'click .joinRequest': 'joinRequest'

  joinRequest: ->
    @model.requestToJoin()
    .catch behaviorsPlugin.Fail.call(@, 'joinRequest')
