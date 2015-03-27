module.exports = BookLi = Backbone.Marionette.ItemView.extend
  template: require './templates/book_li'
  tagName: "li"
  className: "bookLi"

  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'add:pictures', @render
    app.request('qLabel:update')

  events:
    'click a.addToInventory': 'showItemCreationForm'

  showSelectedEntity: (e)->
    app.execute 'show:entity:from:model', @model

  showItemCreationForm: ->
    app.execute 'show:item:creation:form', {entity: @model}