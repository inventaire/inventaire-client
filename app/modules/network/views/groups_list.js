import GroupLi from './group_li.js'
export default Marionette.CollectionView.extend({
  className: 'groupsList',
  tagName: 'ul',
  childView: GroupLi
})
