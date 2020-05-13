{ listingsData } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'
{ deleteShelf } = require 'modules/shelves/lib/shelf'
{ updateShelf } = require 'modules/shelves/lib/shelf'

module.exports = Marionette.LayoutView.extend
  class: 'ShelfEditor'
  template: require './templates/shelf_editor'

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validateButton': 'updateShelfAction'
    'click .listingChoice': 'updateListing'
    'click .deleteButton': 'askDeleteShelf'

  initialize: ->
    listing = @model.get('listing')
    listings = listingsData()
    @model.set('selected', listings[listing])

  serializeData: ->
    listings = listingsData()
    attrs = @model.toJSON()
    _.extend attrs,
      listings: listings
      selected: @model.get('selected')

  onShow: -> app.execute 'modal:open'

  updateListing: (e)->
    if e.currentTarget? then { id } = e.currentTarget
    listings = listingsData()
    @model.set('selected', listings[id])
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
    selected = @model.get('selected')
    updateShelf {
      shelf: shelfId,
      name,
      description,
      listing: selected.id
    }
    .then (updatedShelf) =>
      @model.set(updatedShelf)
      @model.set('icon', selected.icon)
      @model.set('label', selected.label)
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
