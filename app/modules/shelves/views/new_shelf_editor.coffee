ShelfModel = require '../models/shelf'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
{ listingsData } = require 'modules/inventory/lib/item_creation'
{ createShelf } = require 'modules/shelves/lib/shelf'
{ startLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelf_editor'
  behaviors:
    AlertBox: {}
    BackupForm: {}
    ElasticTextarea: {}
    Loading: {}

  initialize: ->
    lastListing = app.request('last:listing:get') or 'private'
    @selected = listingsData()[lastListing]
    @collection = @options.collection

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validate': 'createShelf'
    'click .listingChoice': 'updateListing'

  serializeData: ->
    isNewShelf: true
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
    if description is '' then description = null
    startLoading.call @, '.validate .loading'
    createShelf { name, description, listing: @selected.id }
    .then afterCreate(@collection)
    .catch forms_.catchAlert.bind(null, @)

afterCreate = (collection) -> (newShelf) ->
  newShelfModel = new ShelfModel newShelf
  collection.add newShelfModel
  app.user.trigger 'shelves:change', 'addShelf'
  app.execute 'show:shelf', newShelfModel
  app.execute 'modal:close'
