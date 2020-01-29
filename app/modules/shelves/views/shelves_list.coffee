{ listingsData:listingsDataFn } = require 'modules/inventory/lib/item_creation'

ShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_li'

  events:
    'click .editButton': 'showUpdateShelfEditor'
    'click a.cancelShelfEdition': 'hideShelfEditor'
    'click a.updateShelf': 'updateShelf'
    'click .deleteButton': 'deleteShelf'
    'click .listingChoice': 'updateListing'

  initialize: ->
    @listenTo @model, 'change', @render.bind(@)
    listing = @model.get 'listing'
    @listingData = listingsDataFn()[listing]

  serializeData: ->
    listingsData = listingsDataFn()
    attrs = @model.toJSON()
    _.extend attrs,
      listingsData: listingsData
      listingData: @listingData

  showShelf: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:shelf', @model.get('_id')

  showUpdateShelfEditor: (e)->
    shelfId = @model.get '_id'
    $("##{shelfId}").hide()
    $(".shelfName").val(@model.get('name'))
    $(".shelfDesc").val(@model.get('description'))
    $("##{shelfId}Editor").show().find('textarea').focus()
    e?.stopPropagation()

  hideShelfEditor: (e)->
    shelfId = @model.get '_id'
    $("##{shelfId}Editor").hide()
    $("##{shelfId}").show()
    e?.stopPropagation()

  updateListing: (e)->
    if e.currentTarget? then { id:listing, className } = e.currentTarget
    @listingData = listingsDataFn()[listing]
    @render()
    @showUpdateShelfEditor()

  updateShelf: (e)->
    id = @model.get '_id'
    @hideShelfEditor()
    name = $("##{id}Name").val()
    description = $("##{id}Desc").val()
    listing = @listingData.id
    _.preq.post app.API.shelves.update, { id, name, description, listing }
    .then (updatedShelf) => @model.set(updatedShelf)
    .catch _.Error('shelf update error')

  deleteShelf: (e)->
    id = @model.get '_id'
    _.preq.post app.API.shelves.delete, { ids:id }
    .then => @model.collection.remove @model
    .then _.Log('shelf destroyed')
    .catch _.Error('shelf delete error')

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfLi
