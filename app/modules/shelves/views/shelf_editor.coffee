{ listingsData } = require 'modules/inventory/lib/item_creation'
forms_ = require 'modules/general/lib/forms'
getActionKey = require 'lib/get_action_key'
{ deleteShelf, updateShelf } = require 'modules/shelves/lib/shelf'
{ startLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/shelf_editor'

  behaviors:
    AlertBox: {}
    BackupForm: {}
    ElasticTextarea: {}
    Loading: {}

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validate': 'updateShelfAction'
    'click .listingChoice': 'updateListing'
    'click .delete': 'askDeleteShelf'

  initialize: ->
    listing = @model.get('listing')
    listings = listingsData()
    @model.set('selected', listings[listing])

  serializeData: ->
    listings = listingsData()
    attrs = @model.toJSON()
    _.extend attrs,
      isNewShelf: false
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
    if description is '' then description = null
    selected = @model.get('selected')
    startLoading.call @, '.validate .loading'
    updateShelf {
      shelf: shelfId,
      name,
      description,
      listing: selected.id
    }
    .catch (err)->
      if err.message is 'nothing to update' then return
      else throw err
    .then (updatedShelf) =>
      @model.set updatedShelf
      @model.set 'icon', selected.icon
      @model.set 'label', selected.label
      @closeModal()
    .catch forms_.catchAlert.bind(null, @)

  askDeleteShelf: ->
    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'delete_shelf_confirmation', { name: @model.get('name') }
      warningText: _.i18n 'cant_undo_warning'
      action: deleteShelfAction(@model)
      altAction: deleteShelfAction(@model, true)
      altActionText: _.i18n 'yes and delete shelf items too'

deleteShelfAction = (model, withItems) -> ->
  id = model.get '_id'
  params = { ids: id }
  if withItems then params = _.extend({ 'with-items': true }, params)
  deleteShelf params
  .then _.Log('shelf destroyed')
  .then afterShelfDelete
  .catch _.ErrorRethrow('shelf delete error')

afterShelfDelete = (res)->
  { items } = res
  app.execute 'show:inventory:main:user'
  app.user.trigger 'shelves:change', 'removeShelf'
  items.forEach (item)->
    { listing } = item
    if listing
      app.user.trigger 'items:change', listing, null
