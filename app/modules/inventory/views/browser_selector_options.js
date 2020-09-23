export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: require('./browser_selector_li')
})
