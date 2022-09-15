import { isOpenedOutside, clickCommand } from '#lib/utils'
import userProfileTemplate from './templates/user_profile.hbs'
import { buildPath } from '#lib/location'
import PreventDefault from '#behaviors/prevent_default'
import RelationsActions from '#users/behaviors/relations_actions'
import ShelfEditor from '#shelves/components/shelf_editor.svelte'

// TODO: add a 'close' button to allow to unfocus a user in group context
export default Marionette.View.extend({
  className: 'userProfile',
  template: userProfileTemplate,
  events: {
    'click .editProfile': clickCommand('show:settings:profile'),
    'click .addItems': clickCommand('show:scan'),
    'click .showUserOnMap': 'showUserOnMap',
    'click #createShelf': 'showNewShelfEditor'
  },

  behaviors: {
    PreventDefault,
    RelationsActions,
  },

  initialize () {
    ({ isMainUser: this.isMainUser } = this.model)
    this.listenTo(this.model, 'change', this.render.bind(this))
  },

  serializeData () {
    // Show private items in items counts if available
    const nonPrivate = false
    return _.extend(this.model.serializeData(nonPrivate), {
      onUserProfile: true,
      loggedIn: app.user.loggedIn,
      positionUrl: this.getPositionUrl(),
      distance: this.model.distanceFromMainUser
    })
  },

  getPositionUrl () {
    if (this.model.distanceFromMainUser == null) return
    const [ lat, lng ] = this.model.get('position')
    return buildPath('/network/users/nearby', { lat, lng })
  },

  showUserOnMap (e) {
    if (isOpenedOutside(e)) return
    if (this.model.distanceFromMainUser == null) return
    app.execute('show:models:on:map', [ this.model, app.user ])
  },

  showNewShelfEditor () {
    app.layout.showChildComponent('modal', ShelfEditor)
  }
})
