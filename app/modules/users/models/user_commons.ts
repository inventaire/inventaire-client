import Positionable from '#general/models/positionable'
import { isNonEmptyString } from '#lib/boolean_tests'
import error_ from '#lib/error'
import { images } from '#lib/urls'
import { countListings } from '#listings/lib/listings'
import { countShelves } from '#shelves/lib/shelves'
import { i18n } from '#user/lib/i18n'
import { getUserPathnames } from '#users/lib/users'

const { defaultAvatar } = images

export default Positionable.extend({
  setPathname () {
    const username = this.get('username')
    const pathnames = getUserPathnames(username)
    this.set(pathnames)
    // Set for compatibility with interfaces expecting a label
    // such as modules/inventory/views/browser_selector
    this.set('label', username)
  },

  matchable () {
    return [
      this.get('username'),
      this.get('bio'),
    ]
  },

  updateMetadata () {
    return {
      title: this.get('username'),
      description: this.getDescription(),
      image: this.get('picture'),
      url: this.get('pathname'),
      rss: this.getRss(),
      // Prevent having a big user picture as card
      // See https://github.com/inventaire/inventaire/issues/402
      smallCardType: true,
    }
  },

  getDescription () {
    const bio = this.get('bio')
    if (isNonEmptyString(bio)) {
      return bio
    } else {
      return i18n('user_default_description', { username: this.get('username') })
    }
  },

  async setInventoryStats () {
    const created = this.get('created') || 0
    // Make lastAdd default to the user creation date
    let data = { itemsCount: 0, lastAdd: created }

    const snapshot = this.get('snapshot')
    // Known case of missing snapshot data: user documents return from search
    if (snapshot != null) {
      data = _.values(snapshot).reduce(aggregateScoreData, data)
    }

    const { itemsCount, lastAdd } = data
    // Setting those as model attributes
    // so that updating them trigger a model 'change' event
    this.set('itemsCount', itemsCount)
    this.set('itemsLastAdded', lastAdd)

    const [ shelvesCount, listingsCount ] = await Promise.all([
      countShelves(this.get('_id')),
      countListings(this.get('_id')),
    ])
    this.set('shelvesCount', shelvesCount)
    this.set('listingsCount', listingsCount)
  },

  getRss () { return app.API.feeds('user', this.id) },

  checkSpecialStatus () {
    if (this.get('special')) {
      throw error_.new("this layout isn't available for special users", 400, { user: this })
    }
  },

  setDefaultPicture () {
    if (this.get('picture') == null) this.set('picture', defaultAvatar)
  },
})

const aggregateScoreData = function (data, snapshotSection) {
  const { 'items:count': count, 'items:last-add': lastAdd } = snapshotSection
  data.itemsCount += count
  if (lastAdd > data.lastAdd) data.lastAdd = lastAdd
  return data
}
