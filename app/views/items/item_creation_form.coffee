CategoryMenu = require 'views/items/form/category_menu'
Book = require 'views/items/form/book'
Other = require 'views/items/form/other'
ValidationButtons = require 'views/items/form/validation_buttons'

module.exports =  class ItemCreationForm extends Backbone.Marionette.LayoutView
  template: require "views/items/templates/item_form"
  ui:
    check: '.check'

  regions:
    step1: '#step1'
    step2: '#step2'
    preview: '#preview'
    validation: '#validation'

  categories:
    label: {text: '-- What kind of object is it? --', value: 'label'}
    book: {text: 'book', value: 'book'}
    other: {text: 'something else', value: 'other'}

  onShow: ->
    app.commands.execute 'modal:open'
    @step1.show new CategoryMenu {model: @categories}
    # @validation.show new ValidationButtons

  behaviors:
    SuccessCheck: {}

  events:
    'change #category': 'showStep2'
    'click #validate': 'validateNewItemForm'
    'click #cancel': -> app.commands.execute 'modal:close'

  showStep2: ->
    selected = $('#category').val()
    switch selected
      when 'label' then @step2.empty()
      when 'book' then @step2.show new Book
      when 'other' then @step2.show new Other

  serializeData: ->
    return { status: 'Add a new item to your Inventory' }

  validateNewItemForm: (e)->
    e.preventDefault()
    newItem =
      _id: app.Lib.idGenerator(6)
      title: $('#title').val()
      comment: $('#comment').val()
      owner: app.user.get('_id')
      created: new Date()

    itemModel = app.items.create newItem
    itemModel.username = app.user.get('username')
    @$el.trigger 'check', -> app.commands.execute 'modal:close'