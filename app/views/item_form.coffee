itemFormTemplate = require "views/templates/create_item_form"

module.exports = ItemForm = Backbone.View.extend
  el: '#item-form'
  template: itemFormTemplate
  initialize: ->
    @render()
  render: ->
    @$el.html @template
    console.log window.app
    return @