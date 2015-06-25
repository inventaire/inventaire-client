unselectPlugin = require 'modules/inventory/plugins/unselect'

module.exports = Marionette.ItemView.extend
  getTemplate: ->
    if @options.highlighted then require './templates/group_show'
    else require './templates/group'
  className: 'group'
  tagName: 'li'
  initialize: ->
    @initPlugin()

  initPlugin: ->
    unselectPlugin.call @

  behaviors:
    PreventDefault: {}

  events:
    'click .showGroup': 'showGroup'

  onShow: ->
    if @options.highlighted
      app.execute 'current:username:set', @model.get('name')

  onDestroy: ->
    if @options.highlighted
      app.execute 'current:username:hide'

  showGroup: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:group', @model

  serializeData:->
    _.extend @model.serializeData(),
      highlighted: @options.highlighted
