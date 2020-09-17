ShelfModel = require '../models/shelf'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
{ listingsData } = require 'modules/inventory/lib/item_creation'
{ createShelf: createShelfModel } = require 'modules/shelves/lib/shelf'
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
    createShelfModel { name, description, listing: @selected.id }
    .then afterCreate
    .catch forms_.catchAlert.bind(null, @)

afterCreate = (newShelf) ->
  newShelfModel = new ShelfModel newShelf
  app.user.trigger 'shelves:change', 'createShelf'
  app.execute 'show:shelf', newShelfModel
  app.execute 'modal:close'
  @render()
