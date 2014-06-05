ItemLi = require "views/item_li"
# itemTemplate = require "views/templates/item"


module.exports = ItemListView = Backbone.View.extend
  el: '#item-list'
  tagName: "li"
  className: "item-row"
  # template: itemTemplate
  initialize: (items)->
    @items = items
    @render()
  render: ->
    @$el.html('')
    @items.each (item)=>
      itemLi = new ItemLi {model: item}
      itemLi.render()
      @$el.append itemLi.el
    return @
