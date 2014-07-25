module.exports = class ItemEditionForm extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/item_form'
  onShow: -> app.commands.execute 'modal:open'
  ui:
    check: '.check'
  behaviors:
    SuccessCheck: {}
  events:
    'click #validate': 'updateItem'
    'click #cancel': -> app.commands.execute 'modal:close'

  updateItem: (e)->
    e.preventDefault()
    ['title', 'comment'].forEach (attr)=>
      updatedAttr = $('#' + attr).val()
      _.log "[#{attr}:update] #{updatedAttr}"
      @model.set(attr, updatedAttr)

    unless _.isEmpty @model.changed
      @model.save()
      .then (res)->
        _.log res, 'item successfully saved to the server!'
        @$el.trigger 'check', -> app.commands.execute 'modal:close'
      .fail (err)-> _.log err, 'server error:'
    else
      _.log 'not check'
      app.commands.execute 'modal:close'