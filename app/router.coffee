ItemView = require "views/item_view"
Items = require "collections/items"

module.exports = Backbone.Router.extend
  routes:
    "": "home"
    "personal-inventory":"personalInventory"

  home: ->
    console.log "hello home!"
    this.navigate("/personal-inventory", true)

  personalInventory: ->
    console.log "hello personal inventory!"
    items = new Items

    items.on "add", (item)->
      console.log "Ahoy " + item.get("title") + "!"
      # console.dir item
      itemView = new ItemView {model: item}
      itemView.render()

    window.a = items.add {title: "hello 1!"}
    window.b = items.add {title: "hello 2!"}
    window.c = items.add {title: "hello 3!"}