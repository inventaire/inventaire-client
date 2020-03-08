ConfirmationModal = require 'modules/general/views/confirmation_modal'
{ listingsData:listingsDataFn } = require 'modules/inventory/lib/item_creation'

ShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_li'
  regions:
    modal: '#modalContent'

  events:
    'click .shelfLiInfo': 'showShelf'

  initialize: ->
    @listenTo @model, 'change', @render.bind(@)

  showShelf: (e)->
    app.execute 'show:shelf', @model.get('_id')

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfLi
