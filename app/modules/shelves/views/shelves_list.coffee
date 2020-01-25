ShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_li'

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfLi
