import { capitalise } from 'lib/utils'
import { props as promiseProps, tap } from 'lib/promises'
import { isNonEmptyString, isEntityUri } from 'lib/boolean_tests'
import { i18n } from 'modules/user/lib/i18n'
import preq from 'lib/preq'
import Filterable from 'modules/general/models/filterable'
import error_ from 'lib/error'
import saveOmitAttributes from 'lib/save_omit_attributes'
import { transactionsDataFactory } from '../lib/transactions_data'

export default Filterable.extend({
  initialize (attrs, options) {
    this.testPrivateAttributes()

    const { entity, owner } = attrs

    this.mainUserIsOwner = owner === app.user.id

    if (!isEntityUri(entity)) {
      throw error_.new(`invalid entity URI: ${entity}`, attrs)
    }

    this.entityUri = entity

    this.setPathname()

    this.entityPathname = app.request('get:entity:local:href', this.entityUri)

    if (attrs.shelves == null) this.set('shelves', [])

    this.initUser(owner)
  },

  initUser (owner) {
    // Check the main user early, so that we can access authorized data directly on first render
    if (this.mainUserIsOwner) {
      this.user = app.user
      this.userReady = true
      this.waitForUser = Promise.resolve()
      return this.setUserData()
    } else {
      this.userReady = false
      this.waitForUser = this.reqGrab('get:user:model', owner, 'user')
        .then(this.setUserData.bind(this))
      return this.waitForUser
    }
  },

  // Checking that attributes privacy is as expected
  testPrivateAttributes () {
    const hasPrivateAttributes = (this.get('listing') != null)
    if (this.get('owner') === app.user.id) {
      if (!hasPrivateAttributes) {
        error_.report('item missing private attributes', this)
      }
    } else {
      if (hasPrivateAttributes) {
        error_.report('item has private attributes', this)
      }
    }
  },

  grabEntity () {
    this.waitForEntity = this.waitForEntity || this.reqGrab('get:entity:model', this.entityUri, 'entity')
    return this.waitForEntity
  },

  grabWorks () {
    if (this.waitForWorks != null) { return this.waitForWorks }

    this.waitForWorks = this.grabEntity()
      .then(entity => {
        if (entity.type === 'work') return [ entity ]
        else return entity.waitForWorks
      })
      .then(works => this.grab('works', works))

    return this.waitForWorks
  },

  setUserData () {
    const { user } = this
    this.username = user.get('username')
    this.authorized = (user.id != null) && (user.id === app.user.id)
    this.restricted = !this.authorized
    this.userReady = true
    this.trigger('user:ready')
  },

  setPathname () { return this.set('pathname', '/items/' + this.id) },

  serializeData () {
    const attrs = this.toJSON()

    _.extend(attrs, {
      title: this.get('snapshot.entity:title'),
      personalizedTitle: this.findBestTitle(),
      subtitle: this.get('snapshot.entity:subtitle'),
      entityPathname: this.entityPathname,
      restricted: this.restricted,
      userReady: this.userReady,
      mainUserIsOwner: this.mainUserIsOwner,
      user: this.userData(),
      isPrivate: attrs.listing === 'private'
    })

    // @entity will be defined only if @grabEntity was called
    if (this.entity != null) {
      attrs.entityData = this.entity.toJSON()
      const { type } = this.entity
      attrs.entityType = type
      const Type = capitalise(type)
      attrs[`entityIs${Type}`] = true
    }

    const { transaction } = attrs
    const transacs = transactionsDataFactory()
    attrs.currentTransaction = transacs[transaction]
    attrs[transaction] = true

    if (this.authorized) {
      attrs.transactions = transacs
      attrs.transactions[transaction].classes = 'selected'

      const { listing } = attrs
      attrs.currentListing = app.user.listings()[listing]
      attrs.listings = app.user.listings()
      attrs.listings[listing].classes = 'selected'
    } else {
      // used to hide the "request button" given accessible transactions
      // are necessarly involving the main user, which should be able
      // to have several transactions ongoing with a given item
      attrs.hasActiveTransaction = this.hasActiveTransaction()
    }

    // picture may be undefined
    attrs.picture = this.getPicture()
    attrs.authors = this.get('snapshot.entity:authors')
    attrs.series = this.get('snapshot.entity:series')
    attrs.ordinal = this.get('snapshot.entity:ordinal')

    return attrs
  },

  userData () {
    if (this.userReady) {
      const { user } = this
      return {
        username: this.username,
        picture: user.get('picture'),
        pathname: user.get('pathname'),
        distance: user.distanceFromMainUser
      }
    }
  },

  matchable () {
    return [
      this.get('snapshot.entity:title'),
      this.get('snapshot.entity:authors'),
      this.get('snapshot.entity:series'),
      this.username,
      this.get('details'),
      this.get('notes'),
      this.get('entity')
    ]
  },

  // passing id and rev as query paramaters
  destroy () {
    // reproduce the behavior from the default Bacbkone::destroy
    this.trigger('destroy', this, this.collection)
    return preq.post(app.API.items.deleteByIds, { ids: [ this.id ] })
    .then(tap(() => { this.isDestroyed = true }))
  },

  // to be called by a view onShow:
  // updates the document with the item data
  updateMetadata () {
    // start by adding the entity's metadata
    // and then override by the data available on the item
    return Promise.all([
      // wait for every model the item model depends on
      this.waitForUser,
      this.grabEntity()
    ])
    // /!\ cant be replaced by @entity.updateMetadata.bind(@entity)
    // as @entity is probably undefined yet
    .then(() => this.entity.updateMetadata())
    .then(this.executeMetadataUpdate.bind(this))
  },

  executeMetadataUpdate () {
    return promiseProps({
      title: this.findBestTitle(),
      description: this.findBestDescription()?.slice(0, 501),
      image: this.getPicture(),
      url: this.get('pathname')
    })
  },

  getPicture () { return this.get('pictures')?.[0] || this.get('snapshot.entity:image') },

  findBestTitle () {
    const title = this.get('snapshot.entity:title')
    const transaction = this.get('transaction')
    const context = i18n(`${transaction}_personalized`, { username: this.username })
    return `${title} - ${context}`
  },

  findBestDescription () {
    const details = this.get('details')
    if (isNonEmptyString(details)) {
      return details
    } else {
      return this.entity.findBestDescription()
    }
  },

  hasActiveTransaction () {
    // the reqres 'has:transactions:ongoing:byItemId' wont be defined
    // if the user isn't logged in
    if (!app.user.loggedIn) { return false }
    return app.request('has:transactions:ongoing:byItemId', this.id)
  },

  // Omit pathname on save, as is expected to be found in the model attributes
  // in the client, but is an invalid attribute from the server point of view
  save: saveOmitAttributes('pathname'),

  // Gather save actions
  lazySave (key, value) {
    // Created a debounced save function if non was created before
    if (!this._lazySave) { this._lazySave = _.debounce(this.save.bind(this), 200) }
    // Set any passed
    this.set(key, value)
    // Trigger it
    return this._lazySave()
  },

  getCoords () { return this.user?.getCoords() },

  hasPosition () { return this.user?.has('position') },

  createShelf (shelfId) {
    const shelvesIds = this.get('shelves') || []
    if (shelvesIds.includes(shelfId)) return
    shelvesIds.push(shelfId)
    return this.set('shelves', shelvesIds)
  },

  removeShelf (shelfId) {
    let shelvesIds = this.get('shelves') || []
    if (!shelvesIds.includes(shelfId)) return
    shelvesIds = _.without(shelvesIds, shelfId)
    return this.set('shelves', shelvesIds)
  },

  isInShelf (shelfId) {
    const shelvesIds = this.get('shelves')
    if (!shelvesIds) { return false }
    return shelvesIds.includes(shelfId)
  }
})
