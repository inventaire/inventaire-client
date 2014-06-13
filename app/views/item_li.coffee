itemTemplate = require "views/templates/item"

module.exports = ItemLi = Backbone.View.extend
  tagName: "li"
  className: "item row"
  template: itemTemplate

  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove

  render: ->
    @$el.html @template(@model.attributes)
    return @

  events:
    'click .remove': 'destroy'

  destroy: ->
    console.log 'remove' + @
    @model.destroy()