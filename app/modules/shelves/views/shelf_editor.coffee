{ listingsData } = require 'modules/inventory/lib/item_creation'
forms_ = require 'modules/general/lib/forms'
getActionKey = require 'lib/get_action_key'
UpdateSelector = require 'modules/inventory/behaviors/update_selector'
{ deleteShelf, updateShelf } = require 'modules/shelves/lib/shelf'
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
    'click a.validate': 'validateAction'
    'click .delete': 'askDeleteShelf'

  serializeData: ->
    _.extend @model.toJSON(),
      listings: listingsData()

  onShow: ->
    app.execute 'modal:open'
    listing = @model.get('listing')
    $el = @$el.find("##{listing}")
    $el.siblings().removeClass 'selected'
    $el.addClass 'selected'

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      closeModal()
    else if key is 'enter' and e.ctrlKey
      @validateAction()

  validateAction: (e)->
    shelfId = @model.get('_id')
    name = $('#shelfNameEditor').val()
    description = $('#shelfDescEditor').val()
    if description is '' then description = null
    selected = app.request('last:listing:get')
    startLoading.call @, '.validate .loading'
    updateShelf {
      shelf: shelfId,
      name,
      description,
      listing: selected
    }
    .catch (err)->
      if err.message is 'nothing to update' then return
      else throw err
    .then afterUpdate(selected, @model)
    .then closeModal
    .catch forms_.catchAlert.bind(null, @)

  askDeleteShelf: ->
    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'delete_shelf_confirmation', { name: @model.get('name') }
      warningText: _.i18n 'cant_undo_warning'
      action: deleteShelfAction(@model)

closeModal = (e) -> app.execute 'modal:close'

afterUpdate = (selected, model) -> (updatedShelf) =>
  app.user.trigger 'shelves:change', 'createShelf'
  listingData = listingsData()[selected]
  model.set updatedShelf
  model.set 'icon', listingData.icon
  model.set 'label', listingData.label

deleteShelfAction = (model, withItems) -> ->
  id = model.get '_id'
  params = { ids: id }
  if withItems then params = _.extend({ 'with-items': true }, params)
  deleteShelf params
  .then _.Log('shelf destroyed')
  .then afterShelfDelete
  .catch _.ErrorRethrow('shelf delete error')

afterShelfDelete = (res)->
  app.execute 'show:inventory:main:user'
  app.user.trigger 'shelves:change', 'removeShelf'
  { items } = res
  if items?
    items.forEach (item)->
      { listing } = item
      if listing
        app.user.trigger 'items:change', listing, null
