import app from '#app/app'
import { isOpenedOutside } from '#app/lib/utils'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'
import RelationsActions from '../behaviors/relations_actions.ts'
import userLiTemplate from './templates/user_li.hbs'
import '../scss/user_li.scss'

export default Marionette.View.extend({
  tagName: 'li',
  template: userLiTemplate,
  className () {
    const status = this.model.get('status') || 'noStatus'
    const stretch = this.options.stretch ? 'stretch' : ''
    const groupContext = this.options.groupContext ? 'group-context' : ''
    return `userLi ${status} ${stretch} ${groupContext}`
  },

  behaviors: {
    PreventDefault,
    RelationsActions,
    SuccessCheck,
  },

  events: {
    // share js behavior, but avoid css collisions
    'click .select, .select-2': 'selectUser',
  },

  initialize () {
    // mutualizing the view with user in group context
    this.group = this.options.group
    this.groupContext = this.options.groupContext
    this.listenTo(app.vent, `inventory:${this.model.id}:change`, this.lazyRender.bind(this))
  },

  modelEvents: {
    change: 'lazyRender',
    'group:user:change': 'lazyRender',
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
    if (this.groupContext) this.customizeGroupsAttributes(attrs)
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

    attrs.mainUserIsAdmin = this.group.mainUserIsAdmin()
  },

  selectUser (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:inventory:user', this.model)
  },
})
