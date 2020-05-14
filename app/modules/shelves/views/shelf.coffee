{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'
ShelfEditor = require './shelf_editor'
module.exports = Marionette.LayoutView.extend
  class:'shelfLayout'
  template: require './templates/shelf'

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @render.bind(@)

  events:
    'click #showShelfEdit': 'showEditor'
    'click #unselectShelf': 'unselectShelf'


  serializeData: ->
    attrs = @model.toJSON()
    _.extend attrs,
      editable: @isEditable()

  regions:
    shelf: '.shelf'

  unselectShelf: ->
    ownerId = @model.get('owner')
    @triggerMethod 'unselect:shelf'

  isEditable: ->
    return @model.get('owner') is app.user.id

  showEditor: (e)->
    app.layout.modal.show new ShelfEditor { @model }
