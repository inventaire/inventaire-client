module.exports = class ItemEditionForm extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/item_edition'
  behaviors:
    SuccessCheck: {}
  events:
    'click #validate': 'updateItem'
    'click #cancel': -> app.execute 'modal:close'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.status = 'Edit item'
    return attrs

  updateItem: (e)->
    ['title', 'comment'].forEach (attr)=>
      updatedAttr = $('#' + attr).val()
      _.log "[#{attr}:update] #{updatedAttr}"
      @model.set(attr, updatedAttr)

    unless _.isEmpty @model.changed
      @model.save()
      .then (res)=>
        _.log res, 'item successfully saved to the server!'
        @$el.trigger 'check', -> app.execute 'modal:close'
      .fail (err)-> _.log err, 'server error:'
    else
      _.log 'not check'