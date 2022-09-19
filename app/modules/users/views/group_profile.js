import SectionList from '#users/views/users_home_section_list.js'
import { GroupLayoutView } from '#network/views/group_views_commons'
import groupProfileTemplate from './templates/group_profile.hbs'
import AlertBox from '#behaviors/alert_box'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'

export default GroupLayoutView.extend({
  template: groupProfileTemplate,
  className: 'groupProfile',

  regions: {
    membersList: '#membersList'
  },

  modelEvents: {
    // using lazyRender instead of render allow to wait for group.mainUserStatus
    // to be ready (i.e. not to return 'none')
    change: 'lazyRender'
  },

  behaviors: {
    PreventDefault,
    SuccessCheck,
    AlertBox,
  },

  serializeData () {
    return _.extend(this.model.serializeData(), {
      highlighted: this.options.highlighted,
      rss: this.model.getRss(),
      requestsCount: this.getRequestsCount()
    })
  },

  async onRender () {
    await this.model.beforeShow()
    if (this.isIntact()) this.showMembers()
  },

  showMembers () {
    this.showChildView('membersList', new SectionList({
      collection: this.model.members,
      context: 'group',
      group: this.model
    }))
  },

  getRequestsCount () {
    if (this.model.mainUserIsAdmin()) return this.model.get('requested').length
    else return 0
  },
})
