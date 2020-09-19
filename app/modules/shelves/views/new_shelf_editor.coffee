ShelfModel = require '../models/shelf'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
UpdateSelector = require 'modules/inventory/behaviors/update_selector'
{ listingsData } = require 'modules/inventory/lib/item_creation'
{ createShelf: createShelfModel } = require 'modules/shelves/lib/shelves'
{ startLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelf_editor'

  behaviors:
    AlertBox: {}
    BackupForm: {}
    ElasticTextarea: {}
    Loading: {}
    UpdateSelector:
      behaviorClass: UpdateSelector

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validate': 'createShelf'

  serializeData: ->
    isNewShelf: true
    listings: listingsData()

  onShow: -> app.execute 'modal:open'

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
    selectedListing = app.request('last:listing:get')
    createShelfModel { name, description, listing: selectedListing }
    .then afterCreate
    .catch forms_.catchAlert.bind(null, @)

afterCreate = (newShelf) ->
  newShelfModel = new ShelfModel newShelf
  app.user.trigger 'shelves:change', 'createShelf'
  app.execute 'show:shelf', newShelfModel
  app.execute 'modal:close'
