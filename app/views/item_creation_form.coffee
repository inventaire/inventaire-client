module.exports =  class ItemForm extends Backbone.Marionette.ItemView
  # el: '#item-form'
  template: require "views/templates/item_creation_form"
  onShow: -> app.commands.execute 'modal:open'

  events:
    'click #validateNewItemForm': 'validateNewItemForm'
    'click #cancelAddItem': -> app.commands.execute 'modal:close'

  validateNewItemForm: (e)->
    e.preventDefault()
    newItem =
      _id: app.Lib.idGenerator(6)
      title: $('#title').val()
      visibility: $('#visibility').val()
      transactionMode: $('#transactionMode').val()
      comment: $('#comment').val()
      tags: $('#tags').val()
      owner: app.user.get('username')
      created: new Date()

    # $('#title').val('')
    # $('#comment').val('')
    # $('#item-form').fadeOut().html('')
    # $('#addItem').fadeIn()

    console.log "newItem:"
    console.dir newItem
    app.items.create newItem
    # @refresh()
    app.commands.execute 'modal:close'