import { getColorHexCodeFromModelId, getColorSquareDataUri } from 'lib/images'

import error_ from 'lib/error'

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

    // The listing is only known for the main user's shelves
    const shelfListing = this.get('listing')
    if (shelfListing != null) {
      const listingKeys = app.user.listings.data[shelfListing]
      this.set({
        icon: listingKeys.icon,
        label: listingKeys.label
      })
    }

    this.on('change:color', this.setDerivedAttributes.bind(this))
  },

  setDerivedAttributes () {
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
