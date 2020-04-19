{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'
{ deleteShelf } = require 'modules/shelves/lib/shelf'
{ updateShelf } = require 'modules/shelves/lib/shelf'

module.exports = Marionette.LayoutView.extend
  class:'ShelfEditor'
  template: require './templates/shelf_editor'

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validateButton': 'updateShelfAction'
    'click .listingChoice': 'updateListing'
    'click .deleteButton': 'askDeleteShelf'

  serializeData: ->
    listing = @model.get('listing')
    listingsData = listingsDataFn()
    attrs = @model.toJSON()
    _.extend attrs,
      listingsData: listingsData
      listingData: listingsData[listing]
      picture: @model.get('picture')

  onShow: -> app.execute 'modal:open'

  updateListing: (e)->
    if e.currentTarget? then { id:listing } = e.currentTarget
    @model.set('listing', listing)
    @render()

  closeModal: (e)-> app.execute 'modal:close'

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      @closeModal()
    else if key is 'enter' and e.ctrlKey
      @updateShelfAction()

  updateShelfAction: (e)->
    shelfId = @model.get('_id')
    name = $('#shelfNameEditor').val()
    description = $('#shelfDescEditor').val()
    listing = @model.get('listing')
    updateShelf  { shelf:shelfId, name, description, listing }
    .then (updatedShelf) =>
      @model.set(updatedShelf)
      @closeModal()
    .catch _.Error('shelf update error')

  askDeleteShelf: ->
    app.execute('ask:confirmation',
      confirmationText: _.i18n 'delete shelf confirmation', { name: @model.get('name') }
      warningText: _.i18n 'warning shelf delete'
      action: deleteShelfAction(@model)
      altAction: deleteShelfAction(@model, true)
      altActionText: _.i18n 'yes and delete shelf items too'
    )

deleteShelfAction = (model, withItems) -> ->
  id = model.get '_id'
  params = { ids: id }
  if withItems then params = _.extend({ 'with-items': true }, params)
  deleteShelf params
  .then _.Log('shelf destroyed')
  .then afterShelfDelete
  .catch _.Error('shelf delete error')

afterShelfDelete = (res) ->
  { items } = res
  app.execute 'show:inventory:main:user'
  app.user.trigger 'shelves:change', 'removeShelf'
  items.forEach (item)->
    { listing } = item
    if listing
      app.user.trigger 'items:change', listing, null
