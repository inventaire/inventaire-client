module.exports = class ItemLi extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "itemContainer row"
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

  serializeData: ->
    attrs = @model.serializeData()
    attrs.username = _.style attrs.username, 'strong'
    return attrs

  itemEdit: -> app.execute 'show:item:form:edition', @model

  itemShow: -> app.execute 'show:item:show:from:model', @model

  itemDestroy: ->
    app.request 'item:destroy',
      model: @model
      selector: @el