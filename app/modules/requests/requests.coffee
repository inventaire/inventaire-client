RequestItemModal = require './views/request_item_modal'

module.exports = ->
  app.commands.setHandlers
    'show:item:request': API.showItemRequestModal

API =
  showItemRequestModal: (model)->
    app.layout.modal.show new RequestItemModal {model: model}