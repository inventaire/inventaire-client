module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/book_li'
  tagName: "li"
  className: "wikidataEntity row"

  events:
    'click a.itemTitle': 'showSelectedEntity'
    'click a#selectEntity': 'showSelectedEntity'
    'click a#addToInventory': 'addPersonalData'

  showSelectedEntity: (e)->
    e.preventDefault()
    wdEntity = new app.View.Entities.Wikidata {model: @model}
    app.layout.main.show wdEntity
    app.navigate @model.get('pathname')

  addPersonalData: ->
    e.preventDefault()
    app.execute 'show:item:personal:settings:fromEntityModel', @model
