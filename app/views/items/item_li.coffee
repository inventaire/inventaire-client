module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "itemLi row"
  template: require 'views/items/templates/item_li'
  behaviors:
    ConfirmationModal: {}

  initialize: ->
    @listenTo @model, 'change', @render

  events:
    'click .edit': 'editItem'
    'click .remove': 'destroyItem'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.username = @model.username
    attrs.profilePic = @model.profilePic
    attrs.restricted = @model.restricted
    attrs.created = new Date(attrs.created).toLocaleDateString()
    return attrs

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