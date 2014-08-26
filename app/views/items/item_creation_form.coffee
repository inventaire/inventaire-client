module.exports =  class ItemCreationForm extends Backbone.Marionette.LayoutView
  template: require "views/items/templates/item_form"

  behaviors:
    SuccessCheck: {}

  regions:
    step1: '#step1'
    step2: '#step2'
    results1: '#results1'
    results2: '#results2'
    results3: '#results3'
    validation: '#validation'

  events:
    'click #step1 .category': 'showCategorySpecificForm'
    'click #validate': 'validateNewItemForm'
    'click #cancel': -> app.execute 'show:home'


  onShow: -> @step1.show new app.View.Form.CategoryMenu {model: app.Entities.categories}

  showCategorySpecificForm: (e)->
    @results1.empty()
    @results2.empty()
    @validation.empty()
    switch e.currentTarget.id
      when 'label' then @step2.empty()
      when 'book' then @step2.show new app.View.Form.BookForm
      when 'other' then @step2.show new app.View.Form.OtherForm

  serializeData: ->
    return { status: _.i18n 'Add a new item to your Inventory' }

  validateNewItemForm: (e)->
    newItem =
      title: $('#title').val()
      comment: $('#comment').val()
    if app.request('item:validateCreation', newItem)
      @$el.trigger 'check', -> app.execute 'show:inventory:personal'
    else
      console.error 'invalid item data'