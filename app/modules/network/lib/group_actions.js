import preq from 'lib/preq'
import error_ from 'lib/error'

export default {
  inviteUser (user) {
    return this.action('invite', user.id)
    .then(this.updateInvited.bind(this, user))
  },
  // let views catch the error

  updateInvited (user) {
    this.push('invited', {
      user: user.id,
      invitor: app.user.id,
      timestamp: Date.now()
    })
    this.triggeredListChange()
    return triggerUserChange(user)
  },

  acceptInvitation () {
    this.moveMembership(app.user, 'invited', 'members')

    return this.action('accept')
    .catch(this.revertMove.bind(this, app.user, 'invited', 'members'))
  },

  declineInvitation () {
    this.moveMembership(app.user, 'invited', 'declined')

    return this.action('decline')
    .catch(this.revertMove.bind(this, app.user, 'invited', 'declined'))
  },

  joinGroup () {
    // skipping membership process by directly creating membership doc in members list
    this.push('members', {
      user: app.user.id,
      timestamp: Date.now()
    })
    this.triggeredListChange()

    return this.action('request')
    .catch(this.revertMove.bind(this, app.user, null, 'tmp'))
  },

  requestToJoin () {
    // create membership doc in the requested list
    this.push('requested', {
      user: app.user.id,
      timestamp: Date.now()
    })

    this.triggeredListChange()
    return this.action('request')
      .catch(this.revertMove.bind(this, app.user, null, 'requested'))
  },

  cancelRequest () {
    this.moveMembership(app.user, 'requested', 'tmp')
    return this.action('cancel-request')
    .catch(this.revertMove.bind(this, app.user, 'requested', 'tmp'))
  },

  acceptRequest (user) {
    this.moveMembership(user, 'requested', 'members')
    return this.action('accept-request', user.id)
    .catch(this.revertMove.bind(this, user, 'requested', 'members'))
  },

  refuseRequest (user) {
    this.moveMembership(user, 'requested', 'tmp')
    return this.action('refuse-request', user.id)
    .catch(this.revertMove.bind(this, user, 'requested', 'tmp'))
  },

  makeAdmin (user) {
    this.moveMembership(user, 'members', 'admins')
    triggerUserChange(user)
    return this.action('make-admin', user.id)
    .catch(this.revertMove.bind(this, user, 'members', 'admins'))
  },

  kick (user) {
    this.moveMembership(user, 'members', 'tmp')
    return this.action('kick', user.id)
    .catch(this.revertMove.bind(this, user, 'members', 'tmp'))
  },

  leave () {
    const initialCategory = this.mainUserIsAdmin() ? 'admins' : 'members'
    this.moveMembership(app.user, initialCategory, 'tmp')
    return this.action('leave')
    .catch(this.revertMove.bind(this, app.user, initialCategory, 'tmp'))
  },

  async action (action, userId) {
    const res = await preq.put(app.API.groups.base, {
      action,
      group: this.id,
      // requiered only for actions implying an other user
      user: userId
    })
    await this._postActionHooks.bind(this, action)
    return res
  },

  _postActionHooks (action) {
    this.trigger(`action:${action}`)
    return app.vent.trigger('network:requests:update')
  },

  revertMove (user, previousCategory, newCategory, err) {
    this.moveMembership(user, newCategory, previousCategory)
    triggerUserChange(user)
    throw err
  },

  // moving membership object from previousCategory to newCategory
  moveMembership (user, previousCategory, newCategory) {
    const membership = this.findMembership(previousCategory, user)
    if (membership == null) throw error_.new('membership not found', arguments)

    this.without(previousCategory, membership)
    // let the possibility to just destroy the doc
    // by letting newCategory undefined
    if (newCategory != null) this.push(newCategory, membership)

    this.triggeredListChange()

    // Trigger after the lists where updated
    // so that groups filtered collections can correctly re-filter
    if (user.isMainUser) return app.vent.trigger('group:main:user:move')
  },

  triggeredListChange () {
    // avoid using an event name starting by "change:"
    // as Backbone FilteredCollection react on those
    this.trigger('list:change')
    this.trigger('list:change:after')
  }
}

const triggerUserChange = function (user) {
  const trigger = () => user.trigger('group:user:change')
  // delay the event to let the time to the debounced recalculateAllLists to run
  return setTimeout(trigger, 100)
}
