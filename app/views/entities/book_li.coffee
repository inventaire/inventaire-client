module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/book_li'
  tagName: "li"
  className: "wikidataEntity row"
  behaviors:
    PreventDefault: {}

  initialize: ->
    @listenTo @model, 'add:pictures', @render

  events:
    'click a.itemTitle': 'showSelectedEntity'
    'click a#selectEntity': 'showSelectedEntity'
    'click a#addToInventory': 'showItemCreationForm'

  showSelectedEntity: (e)->
    wdEntity = new app.View.Entities.Wikidata {model: @model}
    app.layout.main.show wdEntity
    app.navigate @model.get('pathname')

  showItemCreationForm: ->
    app.execute 'show:item:creation:form', {entity: @model}