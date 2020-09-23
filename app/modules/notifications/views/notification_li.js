import { templates } from '../lib/notifications_types'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className () {
    const status = this.model.get('status')
    // Has className is only run before first render, the status won't be updated
    // which is fine, given that otherwise the status would directly be updated
    // to 'read', without letting the chance to see what was previously 'unread'
    return `notification ${status}`
  },

  getTemplate () {
    const notifType = this.model.get('type')
    const template = templates[notifType]
    if (template == null) { return _.error('notification type unknown') }
    return template
  },

  behaviors: {
    PreventDefault: {}
  },

  modelEvents: {
    change: 'lazyRender',
    grab: 'lazyRender'
  },

  serializeData () { return this.model.serializeData() },

  events: {
    'click .friendAcceptedRequest': 'showUserProfile',
    // includes: .userMadeAdmin .groupUpdate
    'click .groupNotification': 'showGroupSettings'
  },

  showUserProfile (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:user', this.model.user)
    }
  },

  showGroupSettings (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:group:board', this.model.group)
    }
  }
})
