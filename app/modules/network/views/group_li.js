import { GroupItemView } from './group_views_commons';

export default GroupItemView.extend({
  template: require('./templates/group_li'),
  className: 'groupLi',
  tagName: 'li',

  modelEvents: {
    // Using lazyRender instead of render allow to wait for group.mainUserStatus
    // to be ready (i.e. not to return 'none')
    'change': 'lazyRender'
  },

  behaviors: {
    PreventDefault: {},
    SuccessCheck: {}
  }});
