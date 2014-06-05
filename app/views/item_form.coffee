itemFormTemplate = require "views/templates/item_form"

module.exports = ItemForm = Backbone.View.extend
  el: '#item-form'
  template: itemFormTemplate
  render: ->
    @$el.html @template