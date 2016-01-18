itemActions = require '../plugins/item_actions'
plainTextAuthorLink = require 'modules/entities/plugins/plain_text_author_link'

module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/item_row'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @initPlugins()

  initPlugins: ->
    itemActions.call @
    plainTextAuthorLink.call @, true

  serializeData: -> @model.serializeData()

  onRender: ->
    app.execute 'qlabel:update'
