module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/book_li'
  tagName: "li"
  className: "bookLi row"

  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'add:pictures', @render
    app.request('qLabel:update')

  events:
    'click a.itemTitle': 'showSelectedEntity'
    'click a#selectEntity': 'showSelectedEntity'
    'click a#addToInventory': 'showItemCreationForm'

  showSelectedEntity: (e)->
    app.execute 'show:entity:from:model', @model

  showItemCreationForm: ->
    app.execute 'show:item:creation:form', {entity: @model}