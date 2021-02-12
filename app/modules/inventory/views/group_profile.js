import SectionList from './inventory_section_list'
import { GroupLayoutView } from 'modules/network/views/group_views_commons'
import groupProfileTemplate from './templates/group_profile.hbs'

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
    PreventDefault: {},
    SuccessCheck: {},
    AlertBox: {}
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
    this.membersList.show(new SectionList({ collection: this.model.members, context: 'group', group: this.model }))
  },

  getRequestsCount () {
    if (this.model.mainUserIsAdmin()) return this.model.get('requested').length
    else return 0
  },

  childEvents: {
    select (e, type, model) {
      return app.vent.trigger('inventory:select', 'member', model)
    }
  }
})
