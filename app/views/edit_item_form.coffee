EditItemFormTemplate = require 'views/templates/edit_item_form'

module.exports = EditItemForm = Backbone.View.extend
  el: '#editItemForm'
  template: EditItemFormTemplate
  initialize: ->
  render: ->
    @$el.html @template(@model.attributes)
    return @

  events:
    'click #validateEditItemForm': 'updateItem'
    'click #cancelEditItemForm': 'removeForm'

  updateItem: ->
    ['title', 'tags', 'visibility', 'transactionMode', 'comment'].forEach (attr)=>
      updatedAttr = $('#' + attr).val()
      oldAttr = @model.get(attr)
      if updatedAttr != '' && updatedAttr != oldAttr
        console.log "setting '#{attr}' with value: '#{updatedAttr}'"
        @model.set attr, updatedAttr
    @model.save()
    @removeForm()

  removeForm: ->
    @remove()
    $('#addItem').fadeIn()