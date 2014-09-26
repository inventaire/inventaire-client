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
    'click .edit': 'itemEdit'
    'click a.itemShow, img': 'itemShow'
    'click .remove': 'itemDestroy'

  serializeData: -> @model.serializeData()

  itemEdit: -> app.execute 'show:item:form:edition', @model

  itemShow: -> app.execute 'show:item:show:from:model', @model

  itemDestroy: ->
    args =
      title: @model.get 'title'
      model: @model
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n('destroy_item_text', {title: args.title})
      warningText: _.i18n("this action can't be undone")
      actionCallback: (args)-> args.model.destroy()
      actionArgs: args