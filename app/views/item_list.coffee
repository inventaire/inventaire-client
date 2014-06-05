ItemLi = require "views/item_li"
# itemTemplate = require "views/templates/item"


module.exports = ItemListView = Backbone.View.extend
  el: '#item-list'
  initialize: (items)->
    @items = items
    @render()
    @listenTo @items, "add", @renderOne
  render: ->
    @$el.html('')
    @items.each (item)=>
      @renderOne item
    return @

  renderOne: (item)->
    itemLi = new ItemLi {model: item}
    itemLi.render()
    @$el.append itemLi.el