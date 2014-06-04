ItemView = require "views/item_view"
Items = require "collections/items"

module.exports = Backbone.Router.extend
  routes:
    "": "home"
    "personal-inventory":"personalInventory"

  home: ->
    this.navigate("/personal-inventory", true)

  personalInventory: ->
    items = new Items

    items.on "add", (item)->
      console.log "Ahoy " + item.get("title") + "!"
      itemView = new ItemView {model: item}
      itemView.render()

    items.on "sync", (items)->
      console.log "-----sync items:---------"
      items.each((item)->
        console.log item
        itemView = new ItemView {model: item}
        itemView.render()
        )
      console.log "-------------------------"

    items.fetch({reset: true});
    window.items = items
    # window.a = items.create {title: "hello 1!"}
    # window.b = items.create {title: "hello 2!"}
    # window.c = items.create {title: "hello 3!"}