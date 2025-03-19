import { findWhere, property } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import { isNonEmptyString } from '#app/lib/boolean_tests'
import { getColorSquareDataUriFromCouchUuId } from '#app/lib/images'
import log_ from '#app/lib/loggers'
import { getNumberOfDaysAgo } from '#app/lib/time'
import { images } from '#app/lib/urls'
import { capitalize, fixedEncodeURIComponent } from '#app/lib/utils'
import Positionable from '#general/models/positionable'
import { i18n } from '#user/lib/i18n'
// defining all and _recalculateAll methods
import aggregateUsersIds from '../lib/aggregate_users_ids.ts'
import groupActions from '../lib/group_actions.ts'

// @ts-expect-error
const { defaultCover } = images

export default Positionable.extend({
  url: () => API.groups.base,
  initialize () {
    aggregateUsersIds.call(this)
    Object.assign(this, groupActions)
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
    if (this.mainUserIsAdmin()) this.on('change:slug', this.setInferredAttributes.bind(this))
  },

  setInferredAttributes () {
    const slug = fixedEncodeURIComponent(this.get('slug'))
    const base = `/groups/${slug}`

    this.set({
      canonical: base,
      pathname: base,
      inventoryPathname: `${base}/inventory`,
      listingsPathname: `${base}/lists`,
      settingsPathname: `${base}/settings`,
      // non-persisted category used for convinience on client-side
      tmp: [],
    })

    if (this.get('picture') == null) {
      this.set('picture', getColorSquareDataUriFromCouchUuId(this.get('_id')))
    }
  },

  beforeShow () {
    // All the actions to run once before showing any view displaying
    // deep groups data (with statistics, members list, etc), but that can
    // be spared otherwise
    if (this._beforeShowCalledOnce) return this.waitForData
    this._beforeShowCalledOnce = true

    this.initMembersCollection()
    this.initRequestersCollection()

    this.waitForData = Promise.all([
      this.waitForMembers,
      this.waitForRequested,
    ])

    return this.waitForData
  },

  initMembersCollection () { return this.initUsersCollection('members') },
  initRequestersCollection () { return this.initUsersCollection('requested') },
  initUsersCollection (name) {
    // remove all users
    // to re-add all of them
    // while keeping the same object to avoid breaking references
    if (!this[name]) this[name] = new Backbone.Collection()
    this[name].remove(this[name].models)
    const Name = capitalize(name)
    const ids = this[`all${Name}Ids`]()
    this[`waitFor${Name}`] = this.fetchUsers(this[name], ids)
  },

  fetchUsers (collection, userIds) {
    return app.request('get:users:models', userIds)
    .then(collection.add.bind(collection))
    .catch(log_.Error('fetchMembers'))
  },

  getUsersIds (category) {
    return this.get(category).map(property('user'))
  },

  membersCount () { return this.allMembersIds().length },
  requestsCount () {
    // only used to count groups notifications
    // which only concern group admins
    if (this.mainUserIsAdmin()) {
      return this.get('requested').length
    } else {
      return 0
    }
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
        lng: attrs.position[1],
      }
    }

    const mainUserIsMember = this.mainUserIsMember()

    return Object.assign(attrs, {
      mainUserIsAdmin: this.mainUserIsAdmin(),
      mainUserIsMember,
      hasPosition: this.hasPosition(),
      membersCount: this.membersCount(),
    })
  },

  userStatus (user) {
    const { id } = user
    if (this.allMembersIds().includes(id)) return 'member'
    if (this.allInvitedIds().includes(id)) return 'invited'
    if (this.allRequestedIds().includes(id)) return 'requested'
    return 'none'
  },

  userIsAdmin (userId) {
    return this.allAdminsIds().includes(userId)
  },

  mainUserStatus () { return this.userStatus(app.user) },
  mainUserIsAdmin () {
    return this.allAdminsIds().includes(app.user.id)
  },
  mainUserIsMember () {
    return this.allMembersIds().includes(app.user.id)
  },
  mainUserIsInvited () {
    return this.allInvitedIds().includes(app.user.id)
  },

  findMembership (category, user) {
    return findWhere(this.get(category), { user: user.id })
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
    if (!this.mainUserIsAdmin()) return true
    const mainUserIsTheOnlyAdmin = this.allAdminsIds().length === 1
    const thereAreOtherMembers = this.allMembersStrictIds().length > 0
    if (mainUserIsTheOnlyAdmin && thereAreOtherMembers) {
      return false
    } else {
      return true
    }
  },

  userIsLastUser () { return this.allMembersIds().length === 1 },

  updateMetadata () {
    return {
      title: this.get('name'),
      description: this.getDescription(),
      image: this.getCover(),
      url: this.get('canonical'),
      rss: this.getRss(),
    }
  },

  getDescription () {
    const desc = this.get('description')
    if (isNonEmptyString(desc)) {
      return desc
    } else {
      return i18n('group_default_description', { groupName: this.get('name') })
    }
  },

  getCover () { return this.get('picture') || defaultCover },

  getRss () { return API.feeds('group', this.id) },

  matchable () {
    return [
      this.get('name'),
      this.get('description'),
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
      const ageInDays = getNumberOfDaysAgo(this.get('created'))
      // Highlight the group in its early days
      const ageFactor = 50 / (1 + ageInDays)
      total = adminFactor + membersFactor + randomFactor + ageFactor
    }

    // Inverting to get the highest scores first
    this.set('highlightScore', -total)
  },

  boostHighlightScore () {
    const highestScore = this.collection.models[0].get('highlightScore')
    this.set('highlightScore', highestScore * 2)
    return this.collection.sort()
  },
})
