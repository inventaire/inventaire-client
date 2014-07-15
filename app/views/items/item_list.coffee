# ItemLi = require "views/item_li"

# module.exports = ItemListView = Backbone.View.extend
#   el: '#itemsView'
#   initialize: (items)->
#     # @items = items
#     @renderAllFiltered items
#     # @listenTo items, "add", @renderOne

#   renderAllFiltered: (items)->
#     @$el.html ''
#     items.each (item)=>
#       @renderOne item
#     return @

#   # renderAll: ->
#   #   @$el.html ''
#   #   _.each @items.filtered(@items.filterExpr), (item)=>
#   #     @renderOne item
#   #   return @


#   renderOne: (item)->
#     console.log 'renderOne!!'
#     itemLi = new ItemLi {model: item}
#     itemLi.render()
#     @$el.append itemLi.el
#     return @