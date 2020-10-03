import GroupViewsCommons from './group_views_commons'

const {
  GroupItemView
} = GroupViewsCommons

export default GroupItemView.extend({
  template: require('./templates/group_li.hbs'),
  className: 'groupLi',
  tagName: 'li',

  modelEvents: {
    // Using lazyRender instead of render allow to wait for group.mainUserStatus
    // to be ready (i.e. not to return 'none')
    change: 'lazyRender'
  },

  behaviors: {
    PreventDefault: {},
    SuccessCheck: {}
  }
})
