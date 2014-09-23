module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "itemLi row"
  template: require 'views/items/templates/item_li'
  behaviors:
    ConfirmationModal: {}
    PreventDefault: {}

  initialize: ->
    @listenTo @model, 'change', @render

  events:
    'click .edit': 'editItem'
    'click .remove': 'destroyItem'
    'click a.itemShow': ->
      _.log @model, 'model encoded something?'
      app.execute 'show:item:show:from:model', @model

  serializeData: -> @model.serializeData()

  editItem: ->
    app.execute 'show:item:form:edition', @model

  destroyItem: ->
    args =
      title: @model.get 'title'
      model: @model
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n('destroy_item_text', {title: args.title})
      warningText: _.i18n("this action can't be undone")
      actionCallback: (args)-> args.model.destroy()
      actionArgs: args