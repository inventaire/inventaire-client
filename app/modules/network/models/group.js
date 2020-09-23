// defining all and _recalculateAll methods
import aggregateUsersIds from '../lib/aggregate_users_ids'

import groupActions from '../lib/group_actions'
import Positionable from 'modules/general/models/positionable'
import { getColorSquareDataUriFromModelId } from 'lib/images'
const defaultCover = require('lib/urls').images.brittanystevens
const { escapeExpression } = Handlebars

export default Positionable.extend({
  url: app.API.groups.base,
  initialize () {
    aggregateUsersIds.call(this)
    _.extend(this, groupActions)
    this.setInferredAttributes()
    this.calculateHighlightScore()

    // Set for compatibility with interfaces expecting a label
    // such as modules/inventory/views/browser_selector
    this.set('label', this.get('name'))

    // keep internal lists updated
    this.on('list:change', this.recalculateAllLists.bind(this))
    // updated collections once the debounced recalculateAllLists is done
    this.on('list:change:after', this.initMembersCollection.bind(this))
    this.on('list:change:after', this.initRequestersCollection.bind(this))

    // The user can't change the slug if she isn't an admin
    if (this.mainUserIsAdmin()) { return this.on('change:slug', this.setInferredAttributes.bind(this)) }
  },

  setInferredAttributes () {
    let pathname
    const slug = this.get('slug')
    const canonical = (pathname = `/groups/${slug}`)

    this.set({
      canonical,
      pathname,
      boardPathname: `/groups/${slug}/settings`,
      // non-persisted category used for convinience on client-side
      tmp: []
    })

    if (this.get('picture') == null) {
      return this.set('picture', getColorSquareDataUriFromModelId(this.get('_id')))
    }
  },

  beforeShow () {
    // All the actions to run once before showing any view displaying
    // deep groups data (with statistics, members list, etc), but that can
    // be spared otherwise
    if (this._beforeShowCalledOnce) { return this.waitForData }
    this._beforeShowCalledOnce = true

    this.initMembersCollection()
    this.initRequestersCollection()

    return this.waitForData = Promise.all([
      this.waitForMembers,
      this.waitForRequested
    ])
  },

  initMembersCollection () { return this.initUsersCollection('members') },
  initRequestersCollection () { return this.initUsersCollection('requested') },
  initUsersCollection (name) {
    // remove all users
    // to re-add all of them
    // while keeping the same object to avoid breaking references
    if (!this[name]) { this[name] = new Backbone.Collection() }
    this[name].remove(this[name].models)
    const Name = _.capitalise(name)
    const ids = this[`all${Name}Ids`]()
    return this[`waitFor${Name}`] = this.fetchUsers(this[name], ids)
  },

  fetchUsers (collection, userIds) {
    return app.request('get:users:models', userIds)
    .then(collection.add.bind(collection))
    .catch(_.Error('fetchMembers'))
  },

  getUsersIds (category) {
    return this.get(category).map(_.property('user'))
  },

  membersCount () { return this.allMembersIds().length },
  requestsCount () {
    // only used to count groups notifications
    // which only concern group admins
    if (this.mainUserIsAdmin()) {
      return this.get('requested').length
    } else { return 0 }
  },

  serializeData () {
    const attrs = this.toJSON()
    const status = this.mainUserStatus()

    // Not using status alone as that would override users lists:
    // requested, invited etc
    attrs[`status_${status}`] = true

    if (attrs.position != null) {
      // overriding the position latLng array
      attrs.position = {
        lat: attrs.position[0],
        lng: attrs.position[1]
      }
    }

    const mainUserIsMember = this.mainUserIsMember()

    return _.extend(attrs, {
      mainUserIsAdmin: this.mainUserIsAdmin(),
      mainUserIsMember,
      hasPosition: this.hasPosition(),
      membersCount: this.membersCount()
    }
    )
  },

  userStatus (user) {
    let needle, needle1, needle2
    const { id } = user
    if ((needle = id, this.allMembersIds().includes(needle))) {
      return 'member'
    } else if ((needle1 = id, this.allInvitedIds().includes(needle1))) {
      return 'invited'
    } else if ((needle2 = id, this.allRequestedIds().includes(needle2))) {
      return 'requested'
    } else { return 'none' }
  },

  userIsAdmin (userId) {
    let needle
    return (needle = userId, this.allAdminsIds().includes(needle))
  },

  mainUserStatus () { return this.userStatus(app.user) },
  mainUserIsAdmin () {
    let needle
    return (needle = app.user.id, this.allAdminsIds().includes(needle))
  },
  mainUserIsMember () {
    let needle
    return (needle = app.user.id, this.allMembersIds().includes(needle))
  },
  mainUserIsInvited () {
    let needle
    return (needle = app.user.id, this.allInvitedIds().includes(needle))
  },

  findMembership (category, user) {
    return _.findWhere(this.get(category), { user: user.id })
  },

  findInvitation (user) {
    return this.findMembership('invited', user)
  },

  findUserInvitor (user) {
    const invitation = this.findInvitation(user)
    if (invitation != null) {
      return app.request('get:userModel:from:userId', invitation.invitor)
    }
  },

  findMainUserInvitor () { return this.findUserInvitor(app.user) },

  userCanLeave () {
    if (!this.mainUserIsAdmin()) { return true }
    const mainUserIsTheOnlyAdmin = this.allAdminsIds().length === 1
    const thereAreOtherMembers = this.allMembersStrictIds().length > 0
    if (mainUserIsTheOnlyAdmin && thereAreOtherMembers) {
      return false
    } else { return true }
  },

  userIsLastUser () { return this.allMembersIds().length === 1 },

  updateMetadata () {
    return {
      title: this.get('name'),
      description: this.getDescription(),
      image: this.getCover(),
      url: this.get('canonical'),
      rss: this.getRss()
    }
  },

  getDescription () {
    const desc = this.get('description')
    if (_.isNonEmptyString(desc)) {
      return desc
    } else { return _.i18n('group_default_description', { groupName: this.get('name') }) }
  },

  getCover () { return this.get('picture') || defaultCover },

  getRss () { return app.API.feeds('group', this.id) },

  matchable () {
    return [
      this.get('name'),
      this.get('description')
    ]
  },

  // Should only rely on data available without having to fetch users models
  calculateHighlightScore () {
    let total
    if (this.mainUserIsInvited()) {
      // Highlight groups to which the main user is invited but haven't answered
      total = Infinity
    } else {
      let adminFactor
      if (this.mainUserIsAdmin()) {
        // Increase visibility if requests are pending approval
        adminFactor = 20 + (50 * this.get('requested').length)
      } else {
        adminFactor = 0
      }
      const membersFactor = this.membersCount()
      const randomFactor = Math.random() * 20
      const ageInDays = _.daysAgo(this.get('created'))
      // Highlight the group in its early days
      const ageFactor = 50 / (1 + ageInDays)
      total = adminFactor + membersFactor + randomFactor + ageFactor
    }

    // Inverting to get the highest scores first
    return this.set('highlightScore', -total)
  },

  boostHighlightScore () {
    const highestScore = this.collection.models[0].get('highlightScore')
    this.set('highlightScore', highestScore * 2)
    return this.collection.sort()
  }
})
