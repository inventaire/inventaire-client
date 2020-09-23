forms_ = require 'modules/general/lib/forms'
shelves_ = require '../lib/shelves'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'shelf-items-candidate'
  template: require './templates/shelf_items_candidate'

  initialize: ->
    { @shelf } = @options
    @shelfId = @shelf.id

  behaviors:
    AlertBox: {}

  serializeData: ->
    _.extend @model.serializeData(),
      alreadyAdded: @isAlreadyAdded()

  events:
    'click .add': 'addToShelf'
    'click .remove': 'removeFromShelf'
    'click .showItem': 'showItem'

  modelEvents:
    'add:shelves': 'lazyRender'
    'remove:shelves': 'lazyRender'

  showItem: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:item', @model

  addToShelf: ->
    shelves_.addItems @shelf, @model
    .catch forms_.catchAlert.bind(null, @)

  # Do no rename function to 'remove' as that would overwrite
  # Backbone.Marionette.View.prototype.remove
  removeFromShelf: ->
    shelves_.removeItems @shelf, @model
    .catch forms_.catchAlert.bind(null, @)

  isAlreadyAdded: ->
    shelvesIds = @model.get('shelves') or []
    return @shelfId in shelvesIds
