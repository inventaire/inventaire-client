itemTemplate = require "views/templates/item"

module.exports = ItemListView = Backbone.View.extend
  tagName: "li"
  className: "item-row"
  template: itemTemplate
  initialize: ->
    @listenTo @model, "change", @render
  render: ->
    @$el.html @template(@model.attributes)
    $('#item-list').append @$el
    return @
