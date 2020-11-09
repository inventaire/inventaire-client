import { daysAgo } from 'lib/utils'
import UserCommons from './user_commons'
import { distanceBetween } from 'modules/map/lib/geo'

export default UserCommons.extend({
  isMainUser: false,
  initialize () {
    this.setPathname()
    this.setDefaultPicture()

    if (this.hasPosition()) {
      this.listenTo(app.user, 'change:position', this.calculateDistance.bind(this))
      this.calculateDistance()
    }

    this.setInventoryStats()
    this.calculateHighlightScore()

    // A type attribute is required by some views
    // that switch on type to pick a template for instance
    this.set('type', 'user')

    return app.request('wait:for', 'relations')
    .then(this.initRelation.bind(this))
  },

  initRelation () {
    this.set('status', getStatus(this.id, app.relations))

    if (app.relations.network.includes(this.id)) {
      return this.set('itemsCategory', 'network')
    } else {
      return this.set('itemsCategory', 'public')
    }
  },

  serializeData () {
    const attrs = this.toJSON()
    const relationStatus = attrs.status
    // converting the status into a boolean for templates
    attrs[relationStatus] = true
    // nonRelationGroupUser status have the same behavior as public users for views
    if (relationStatus === 'nonRelationGroupUser') {
      attrs.public = true
    }
    attrs.inventoryLength = this.inventoryLength()
    return attrs
  },

  inventoryLength () { return this.get('itemsCount') },

  // caching the calculated distance to avoid recalculating it
  // at every item serializeData
  calculateDistance () {
    if (!app.user.has('position') || !this.has('position')) return

    const a = app.user.getCoords()
    const b = this.getCoords()
    const distance = (this.kmDistanceFormMainUser = distanceBetween(a, b))
    // Under 20km, return a ~100m precision to signal the fact that location
    // aren't precise to the meter or anything close to it
    // Above, return a ~1km precision
    const precision = distance > 20 ? 0 : 1
    this.distanceFromMainUser = Number(distance.toFixed(precision)).toLocaleString(app.user.lang)
  },

  calculateHighlightScore () {
    const [ itemsCount, itemsLastAdded ] = this.gets('itemsCount', 'itemsLastAdded')
    // Highlight users with the most known items
    // updated lately (add 1 to avoid dividing by 0)
    const freshnessFactor = 100 / (daysAgo(itemsLastAdded) + 1)
    // Highlight users nearby
    const distanceFactor = (this.kmDistanceFormMainUser != null) ? 100 / (this.kmDistanceFormMainUser + 1) : 0
    // Well, just highlight anyone actually but don't let that dum per-_id default
    // order. Adapt the multiplicator to let other factors keep the upper ground
    const randomFactor = Math.random() * 50
    const points = itemsCount + freshnessFactor + distanceFactor + randomFactor
    // negating to get the higher scores appear first in collections
    return this.set('highlightScore', -points)
  }
})

const getStatus = function (id, relations) {
  if (relations.friends.includes(id)) {
    return 'friends'
  } else if (relations.userRequested.includes(id)) {
    return 'userRequested'
  } else if (relations.otherRequested.includes(id)) {
    return 'otherRequested'
  } else if (relations.network.includes(id)) {
    return 'nonRelationGroupUser'
  } else {
    return 'public'
  }
}
