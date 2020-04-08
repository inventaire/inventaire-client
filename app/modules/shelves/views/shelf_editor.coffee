{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.LayoutView.extend
  class:'ShelfEditor'
  template: require './templates/shelf_editor'

  events:
    'keydown .shelfEditor': 'shelfEditorKeyAction'
    'click a.validateButton': 'updateShelf'
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

  closeModal: (e)->
    app.execute 'modal:close'

  updateShelf: (e)->
    shelfId = @model.get('_id')
    name = $('#shelfNameEditor').val()
    description = $('#shelfDescEditor').val()
    listing = @model.get('listing')
    _.preq.post app.API.shelves.update, { shelf:shelfId, name, description, listing }
    .get 'shelf'
    .then (updatedShelf) =>
      @model.set(updatedShelf)
      @closeModal()
    .catch _.Error('shelf update error')

  shelfEditorKeyAction: (e)->
    key = getActionKey e
    if key is 'esc'
      @closeModal()
    else if key is 'enter' and e.ctrlKey
      @updateShelf()

  askDeleteShelf: ->
    app.execute('ask:confirmation',
      confirmationText: _.i18n 'delete shelf confirmation', { name: @model.get('name') }
      warningText: _.i18n 'warning shelf delete'
      action: deleteShelf(@model)
      altAction: deleteShelf(@model, true)
      altActionText: _.i18n 'yes and delete shelf items too'
    )

deleteShelf = (model, withItems) -> ->
  id = model.get '_id'
  params = { ids: id }
  if withItems then params = _.extend({ 'with-items': true }, params)
  _.preq.post app.API.shelves.delete, params
  .then _.Log('shelf destroyed')
  .then (res)->
    app.execute 'show:inventory:main:user'
    app.user.trigger 'shelves:change', 'removeShelf'
    items = res.items
    items.forEach (item)->
      if item.listing then app.user.trigger 'items:change', item.listing, null
  .catch _.Error('shelf delete error')
