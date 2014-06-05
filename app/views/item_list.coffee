ItemLi = require "views/item_li"
# itemTemplate = require "views/templates/item"


module.exports = ItemListView = Backbone.View.extend
  el: '#itemsView'
  initialize: (items)->
    @items = items
    @renderAll()
    @listenTo @items, "add", @renderOne

  renderAll: ->
    @$el.html ''
    _.each @items.filtered(@items.filterExpr), (item)=>
      @renderOne item
    return @

  renderOne: (item)->
    itemLi = new ItemLi {model: item}
    itemLi.render()
    @$el.append itemLi.el
    return @