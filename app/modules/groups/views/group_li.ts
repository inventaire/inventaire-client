import { GroupItemView } from './group_views_commons.js'
import groupLiTemplate from './templates/group_li.hbs'
import '../scss/group_li.scss'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'

export default GroupItemView.extend({
  template: groupLiTemplate,
  className: 'groupLi',
  tagName: 'li',

  modelEvents: {
    // Using lazyRender instead of render allow to wait for group.mainUserStatus
    // to be ready (i.e. not to return 'none')
    change: 'lazyRender'
  },

  behaviors: {
    PreventDefault,
    SuccessCheck,
  }
})
