ShelfModel = require '../models/shelf'
ShelfView = require './shelf'
Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'
error_ = require 'lib/error'

module.exports = Marionette.LayoutView.extend
  id: 'shelvesLayout'
  template: require './templates/shelf_layout'
  regions:
    shelf: '.shelf'
    itemsList: '.itemsList'

  onShow: ->
    { shelf: shelfId } = @options
    getById(shelfId)
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (model)->
    { items } = model.attributes
    collection = new Items items

    more = -> items.length > 0
    fetchMore = ->
      batch = items.splice(0, 20).map _.property('_id')
      if batch.length > 0
        app.request 'items:getByIds', batch
        .then collection.add.bind(collection)

    @shelf.show new ShelfView { model }
    @itemsList.show new ItemsList { collection, more, fetchMore }

getById = (id)->
  _.preq.get app.API.shelves.byIds(id)
  .get 'bookshelves'
  .then (shelves)->
    shelf = Object.values(shelves)[0]
    if shelf? then new ShelfModel shelf
    else throw error_.new 'not found', 404, { id }
