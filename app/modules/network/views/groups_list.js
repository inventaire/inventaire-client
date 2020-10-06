import GroupLi from './group_li'
export default Marionette.CollectionView.extend({
  className: 'groupsList',
  tagName: 'ul',
  childView: GroupLi
})
