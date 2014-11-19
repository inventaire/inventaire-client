ItemLi = require './item_li'

module.exports = class ItemFigure extends ItemLi
  tagName: 'figure'
  className: 'itemContainer shadowBox'
  template: require './templates/item_figure'