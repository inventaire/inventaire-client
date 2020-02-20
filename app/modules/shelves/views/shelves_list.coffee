ConfirmationModal = require 'modules/general/views/confirmation_modal'
{ listingsData:listingsDataFn } = require 'modules/inventory/lib/item_creation'

ShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_li'
  regions:
    modal: '#modalContent'

  events:
    'click .editButton': 'showUpdateShelfEditor'
    'click a.cancelShelfEdition': 'hideShelfEditor'
    'click a.updateShelf': 'updateShelf'
    'click .deleteButton': 'askDeleteShelf'
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
    $("##{shelfId}Name").val(@model.get('name'))
    $("##{shelfId}Desc").val(@model.get('description'))
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
    shelf = @model.get '_id'
    @hideShelfEditor()
    name = $("##{shelf}Name").val()
    description = $("##{shelf}Desc").val()
    listing = @listingData.id
    _.preq.post app.API.shelves.update, { shelf, name, description, listing }
    .get('shelf')
    .then (updatedShelf) => @model.set(updatedShelf)
    .catch _.Error('shelf update error')

  askDeleteShelf: ->
    app.execute('ask:confirmation',
      confirmationText: _.i18n 'delete shelf confirmation', { name: @model.get('name') }
      warningText: _.i18n 'warning shelf delete'
      action: @deleteShelf(@model)
      altAction: @deleteShelf(@model, true)
      altActionText: _.i18n 'yes and delete shelf items too'
    )

  deleteShelf: (model, withItems) -> ->
    id = model.get '_id'
    params = { ids: id }
    if withItems then params = _.extend({'with-items': true}, params)
    _.preq.post app.API.shelves.delete, params
    .then => model.collection.remove model
    .then _.Log('shelf destroyed')
    .catch _.Error('shelf delete error')

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfLi
