# ItemView = require "views/item_view"
# Items = require "collections/items"

module.exports = Backbone.Router.extend
  routes:
    "": "home"
#     "personal-inventory":"personalInventory"

  home: ->
    console.log "here"