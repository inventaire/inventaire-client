import GroupLi from './group_li.ts'

export default Marionette.CollectionView.extend({
  className: 'groupsList',
  tagName: 'ul',
  childView: GroupLi,
})
