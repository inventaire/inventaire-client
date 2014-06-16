itemTemplate = require "views/templates/item"
EditItemForm = require "views/edit_item_form"

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
    'click .edit': 'edit'
    'click .remove': 'destroy'

  destroy: ->
    @model.destroy()

  edit: ->
    form = new EditItemForm {model: @model}
    form.render()
    $form = $('#editItemForm').fadeIn()

    if @model.get('visibility') != undefined
      opt1 = "#visibility option[value=" + @model.get('visibility') + "]"
      $(opt1).prop('selected', true);
    if @model.get('transactionMode') != undefined
      opt2 = "#transactionMode option[value=" + @model.get('transactionMode') + "]"
      $(opt2).prop('selected', true);

    $('#addItem').fadeOut()