ShelfModel = require '../models/shelf'
getActionKey = require 'lib/get_action_key'
{ listingsData } = require 'modules/inventory/lib/item_creation'
{ createShelf } = require 'modules/shelves/lib/shelf'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelf_editor'
  behaviors:
    BackupForm: {}

  initialize: ->
    #Default listing
    @selected = listingsData()['private']
    @collection = @options.collection

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validateButton': 'createShelf'
    'click .listingChoice': 'updateListing'

  serializeData: ->
    listings: listingsData()
    selected: @selected

  onShow: -> app.execute 'modal:open'

  updateListing: (e)->
    if e.currentTarget? then { id: listing } = e.currentTarget
    @selected = listingsData()[listing]
    @render()

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      @closeModal()
    else if key is 'enter' and e.ctrlKey
      @createShelf()

  closeModal: -> app.execute 'modal:close'

  createShelf: ->
    name = $('#shelfNameEditor').val()
    description = $('#shelfDescEditor ').val()
    if not name and not description then return
    createShelf { name, description, listing: @selected.id }
    .then afterCreate(@collection)
    .catch _.Error('shelf creation error')

afterCreate = (collection) -> (newShelf) ->
  newShelfModel = new ShelfModel newShelf
  collection.add newShelfModel
  app.user.trigger 'shelves:change', 'addShelf'
  app.execute 'show:shelf', null, newShelf
  app.execute 'modal:close'
