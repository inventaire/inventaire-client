module.exports = class ItemEditionForm extends Backbone.Marionette.ItemView
  # el: '#editItemForm'
  template: require "views/items/templates/item_edition_form"
  # initialize: ->
  # render: ->
  #   @$el.html @template(@model.attributes)
  #   return @

  events:
    'click #validateItemEditionForm': 'validateItemEditionForm'
    'click #cancelItemEditionForm': -> app.commands.execute 'modal:close'

  validateItemEditionForm: ->
    console.log 'validateItemEditionForm!!!'
  #   'click #validateEditItemForm': 'updateItem'
  #   'click #cancelEditItemForm': 'removeForm'

  # updateItem: ->
  #   ['title', 'tags', 'visibility', 'transactionMode', 'comment'].forEach (attr)=>
  #     updatedAttr = $('#' + attr).val()
  #     oldAttr = @model.get(attr)
  #     if updatedAttr != '' && updatedAttr != oldAttr
  #       console.log "setting '#{attr}' with value: '#{updatedAttr}'"
  #       @model.set attr, updatedAttr
  #   @model.save()
  #   @removeForm()

  # removeForm: ->
  #   @remove()
  #   $('#addItem').fadeIn()