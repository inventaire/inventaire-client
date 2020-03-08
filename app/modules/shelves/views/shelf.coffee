{ listingsData: listingsDataFn } = require 'modules/inventory/lib/item_creation'
getActionKey = require 'lib/get_action_key'
ShelfEditor = require './shelf_editor'
module.exports = Marionette.LayoutView.extend
  class:'shelfLayout'
  template: require './templates/shelf'

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @render.bind(@)
    app.commands.setHandlers
      'show:shelf:editor': @showEditor.bind(@)

  events:
    'click #showShelfEdit': 'showEditor'

  serializeData: ->
    attrs = @model.toJSON()
    _.extend attrs,
      editable: @isEditable()

  regions:
    shelf: '.shelf'

  isEditable: ->
    return @model.get('owner') is app.user.id

  showEditor: (e)->
    app.layout.modal.show new ShelfEditor { @model }
