import { getColorHexCodeFromModelId, getColorSquareDataUri } from '#lib/images'

import error_ from '#lib/error'
import { isGroupVisibilityKey } from '#general/lib/visibility'

export default Backbone.Model.extend({
  initialize (attrs) {
    const { name } = attrs

    if (name == null) throw error_.new('invalid shelf', 500, attrs)

    this.set({
      pathname: `/shelves/${attrs._id}`,
      type: 'shelf'
    })

    if (this.get('color') == null) {
      const colorHexCode = getColorHexCodeFromModelId(this.get('_id'))
      this.set('color', colorHexCode)
    }
    this.setDerivedAttributes()
    this.on('change', this.setDerivedAttributes.bind(this))
  },

  setDerivedAttributes () {
    // The visibility is only known for the main user's shelves
    const visibility = this.get('visibility')
    if (visibility != null) {
      const correspondingListing = getCorrespondingListing(visibility)
      const listingKeys = app.user.listings.data[correspondingListing]
      this.set({
        icon: listingKeys.icon,
        label: getIconLabel(visibility)
      })
    }

    this.set('picture', getColorSquareDataUri(this.get('color')))
  },

  updateMetadata () {
    return {
      title: this.get('name'),
      description: this.get('description'),
      image: this.get('picture'),
      url: this.get('pathname'),
      rss: this.getRss(),
    }
  },

  getRss () { return app.API.feeds('shelf', this.id) },
})

const getCorrespondingListing = visibility => {
  if (visibility.length === 0) return 'private'
  if (visibility.includes('public')) return 'public'
  return 'network'
}

const getIconLabel = visibility => {
  if (visibility.length === 0) return 'private'
  if (visibility.includes('public')) return 'public'

  const groupKeyCount = visibility.filter(isGroupVisibilityKey).length
  if (visibility.includes('friends') && visibility.includes('groups')) {
    return 'friends and groups'
  } else if (groupKeyCount > 0) {
    if (visibility.includes('friends')) return 'friends and some groups'
    else return 'some groups'
  } else if (visibility.includes('groups')) {
    return 'groups'
  } else {
    return 'friends'
  }
}
