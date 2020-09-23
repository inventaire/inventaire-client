/* eslint-disable
    no-return-assign,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Model.extend({
  initialize () {
    this.action = this.get('action')
    return this.userReady = false
  },

  serializeData () {
    return _.extend(this.toJSON(), {
      icon: this.icon(),
      context: this.context(true),
      userReady: this.userReady
    }
    )
  },

  icon () {
    switch (this.action) {
    case 'requested': return 'envelope'
    case 'accepted': return 'check'
    case 'confirmed': return 'sign-in'
    case 'declined': case 'cancelled': return 'times'
    case 'returned': return 'check'
    default: return _.warn(this, 'unknown action', true)
    }
  },

  context (withLink) { return this.userAction(this.findUser(), withLink) },
  findUser () {
    if (actorCanBeBoth.includes(this.action)) { return this.findCancelActor() }
    if (this.transaction?.owner != null) {
      if (this.transaction.mainUserIsOwner) {
        if (ownerActions.includes(this.action)) { return 'main' } else { return 'other' }
      } else {
        if (ownerActions.includes(this.action)) { return 'other' } else { return 'main' }
      }
    }
  },

  findCancelActor () {
    const actorIsOwner = this.get('actor') === 'owner'
    const { mainUserIsOwner } = this.transaction
    if (mainUserIsOwner) {
      if (actorIsOwner) { return 'main' } else { return 'other' }
    } else {
      if (actorIsOwner) { return 'other' } else { return 'main' }
    }
  },

  userAction (user, withLink) {
    if (user != null) {
      this.userReady = true
      return _.i18n(`${user}_user_${this.action}`, { username: this.otherUsername(withLink) })
    }
  },

  otherUsername (withLink) {
    const otherUser = this.transaction?.otherUser()
    // injecting an html anchor instead of just a username string
    if (otherUser != null) {
      const [ username, pathname ] = Array.from(otherUser.gets('username', 'pathname'))
      if (withLink) {
        return `<a href='${pathname}' class='username'>${username}</a>`
      } else { return username }
    }
  }
})

var actorCanBeBoth = [ 'cancelled' ]

var ownerActions = [
  'accepted',
  'declined',
  'returned'
]
