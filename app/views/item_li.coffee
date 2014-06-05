itemTemplate = require "views/templates/item"

module.exports = ItemLi = Backbone.View.extend
  tagName: "li"
  className: "item-row"
  template: itemTemplate
  initialize: ->
    @listenTo @model, "change", @render
  render: ->
    @$el.html @template(@model.attributes)
    return @