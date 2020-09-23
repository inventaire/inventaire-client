export default Marionette.CollectionView.extend({
  className: 'groupsList',
  tagName: 'ul',
  childView: require('./group_li')
});
