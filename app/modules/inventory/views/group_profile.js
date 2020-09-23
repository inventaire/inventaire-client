import SectionList from './inventory_section_list'
import { GroupLayoutView } from 'modules/network/views/group_views_commons'

export default GroupLayoutView.extend({
  template: require('./templates/group_profile'),
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
    SuccessCheck: {}
  },

  serializeData () {
    return _.extend(this.model.serializeData(), {
      highlighted: this.options.highlighted,
      rss: this.model.getRss(),
      requestsCount: this.model.get('requested').length
    }
    )
  },

  onRender () {
    return this.model.beforeShow()
    .then(this.ifViewIsIntact('showMembers'))
  },

  showMembers () {
    return this.membersList.show(new SectionList({ collection: this.model.members, context: 'group', group: this.model }))
  },

  childEvents: {
    select (e, type, model) {
      return app.vent.trigger('inventory:select', 'member', model)
    }
  }
})
