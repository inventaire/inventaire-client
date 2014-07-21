module.exports =  class ItemForm extends Backbone.Marionette.ItemView
  template: require "views/items/templates/item_creation_form"
  onShow: -> app.commands.execute 'modal:open'
  events:
    'click #validateNewItemForm': 'validateNewItemForm'
    'click #cancelAddItem': -> app.commands.execute 'modal:close'

  validateNewItemForm: (e)->
    e.preventDefault()
    newItem =
      _id: app.Lib.idGenerator(6)
      title: $('#title').val()
      comment: $('#comment').val()
      owner: app.user.get('_id')
      created: new Date()

    itemModel = app.items.create newItem
    itemModel.set 'username', app.user.get('username')
    app.commands.execute 'modal:close'