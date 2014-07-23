module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "item row"
  template: require 'views/items/templates/item_li'

  initialize: ->
    @listenTo @model, 'change', @render

  events:
    'click .edit': 'editItem'
    'click .remove': 'destroyItem'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.username = @model.username
    attrs.restricted = @model.restricted
    return attrs

  editItem: ->
    app.commands.execute 'item:edit', @model

  destroyItem: ->
    console.log 'what destroy'
    console.dir @
    @model.destroy()