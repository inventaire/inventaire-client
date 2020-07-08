{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'
ShelfEditor = require './shelf_editor'

module.exports = Marionette.ItemView.extend
  className: 'shelfBox'
  template: require './templates/shelf_box'

  initialize: ->
    @isEditable = @model.get('owner') is app.user.id

  events:
    'click #showShelfEdit': 'showEditor'
    'click #unselectShelf': 'unselectShelf'

  modelEvents:
    'change': 'lazyRender'

  serializeData: ->
    attrs = @model.toJSON()
    _.extend attrs,
      isEditable: @isEditable

  unselectShelf: ->
    ownerId = @model.get('owner')
    @triggerMethod 'unselect:shelf'

  showEditor: (e)->
    app.layout.modal.show new ShelfEditor { @model }
