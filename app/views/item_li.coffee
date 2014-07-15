EditItemForm = require "views/edit_item_form"

module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "item row"
  template: require 'views/templates/item'

  initialize: ->
    console.log 'itemli!'
  #   @listenTo @model, "change", @render
  #   @listenTo @model, "destroy", @remove

  events:
    'click .edit': 'edittest'
    'click .remove': 'destroytest'

  edittest: -> console.log 'what edit'
  destroytest: ->
    console.log 'what destroy'
    console.dir @
    @model.destroy()

  # destroy:->
  #   console.log 'DESTROY TRIGGERED'
  #   @model.destroy()

  # edit: ->
  #   console.log 'EDIT TRIGGERED'
  #   form = new EditItemForm {model: @model}
  #   form.render()
  #   $form = $('#editItemForm').fadeIn()

  #   if @model.get('visibility') != undefined
  #     opt1 = "#visibility option[value=" + @model.get('visibility') + "]"
  #     $(opt1).prop('selected', true)
  #   if @model.get('transactionMode') != undefined
  #     opt2 = "#transactionMode option[value=" + @model.get('transactionMode') + "]"
  #     $(opt2).prop('selected', true)

  #   $('#addItem').fadeOut()