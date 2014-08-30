module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/book_li'
  tagName: "li"
  className: "wikidataEntity row"
  serializeData: ->
    return wd.serializeWikiData(@model)

  events:
    'click #selectEntity': 'showSelectedEntity'
    'click #addToInventory': 'addPersonalData'

  showSelectedEntity: (e)->
    e.preventDefault()
    wdEntity = new app.View.Entities.Wikidata {model: @model}
    app.layout.main.show wdEntity
    app.navigate "entity/#{@model.get('id')}"

  addPersonalData: ->
    app.execute 'show:item:personal:settings:fromEntityModel', @model
