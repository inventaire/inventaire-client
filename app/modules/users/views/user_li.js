/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import relationsActions from '../plugins/relations_actions'

export default Marionette.ItemView.extend({
  tagName: 'li',
  template: require('./templates/user_li'),
  className () {
    const classes = 'userLi'
    const status = this.model.get('status') || 'noStatus'
    const stretch = this.options.stretch ? 'stretch' : ''
    const groupContext = this.options.groupContext ? 'group-context' : ''
    return `userLi ${status} ${stretch} ${groupContext}`
  },

  behaviors: {
    PreventDefault: {},
    SuccessCheck: {}
  },

  events: {
    // share js behavior, but avoid css collisions
    'click .select, .select-2': 'selectUser'
  },

  initialize () {
    // mutualizing the view with user in group context
    this.group = this.options.group
    this.groupContext = this.options.groupContext

    this.initPlugins()
    return this.listenTo(app.vent, `inventory:${this.model.id}:change`, this.lazyRender.bind(this))
  },

  modelEvents: {
    change: 'lazyRender',
    'group:user:change': 'lazyRender'
  },

  initPlugins () {
    return relationsActions.call(this)
  },

  serializeData () {
    // nonPrivateInventoryLength is only a concern for the main user
    // which is only shown as a UserLi in the context of a group
    // thus the use of nonPrivateInventoryLength, as only non-private
    // items are integrating the group items counter
    const nonPrivateInventoryLength = true
    const attrs = this.model.serializeData(nonPrivateInventoryLength)
    // required by the invitations by email users list
    attrs.showEmail = this.options.showEmail && (attrs.email != null)
    attrs.stretch = this.options.stretch
    if (this.groupContext) { this.customizeGroupsAttributes(attrs) }
    return attrs
  },

  customizeGroupsAttributes (attrs) {
    attrs.groupContext = true

    const groupStatus = this.group.userStatus(this.model)
    attrs[groupStatus] = true

    const userId = this.model.id

    // Override the general user.admin attribute to display an admin status
    // only for group admins
    attrs.admin = this.group.userIsAdmin(userId)

    return attrs.mainUserIsAdmin = this.group.mainUserIsAdmin()
  },

  selectUser (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:inventory:user', this.model)
    }
  }
})
