module.exports = Marionette.CollectionView.extend
  className: 'groupsList'
  tagName: 'ul'
  childView: require './group_li'
