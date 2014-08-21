CategoryMenu = require 'views/items/form/category_menu'
Book = require 'views/items/form/book'
Other = require 'views/items/form/other'
ValidationButtons = require 'views/items/form/validation_buttons'

module.exports =  class ItemCreationForm extends Backbone.Marionette.LayoutView
  template: require "views/items/templates/item_form"

  regions:
    step1: '#step1'
    step2: '#step2'
    results1: '#results1'
    results2: '#results2'
    results3: '#results3'
    validation: '#validation'

  categories:
    book: {text: 'book', value: 'book', icon: 'book', entity: 'Q571'}
    other: {text: 'something else', value: 'other'}

  onShow: ->
    app.execute 'modal:open'
    @step1.show new CategoryMenu {model: @categories}

  behaviors:
    SuccessCheck: {}

  events:
    'click .category': 'showStep2'
    'click #validate': 'validateNewItemForm'
    'click #cancel': -> app.execute 'modal:close'

  showStep2: (e)->
    @results1.empty()
    @results2.empty()
    @validation.empty()
    switch e.currentTarget.id
      when 'label' then @step2.empty()
      when 'book' then @step2.show new Book
      when 'other' then @step2.show new Other

  serializeData: ->
    return { status: _.i18n 'Add a new item to your Inventory' }

  validateNewItemForm: (e)->
    newItem =
      title: $('#title').val()
      comment: $('#comment').val()
    if app.request('item:validateCreation', newItem)
      @$el.trigger 'check', -> app.execute 'modal:close'
    else
      console.error 'invalid item data'