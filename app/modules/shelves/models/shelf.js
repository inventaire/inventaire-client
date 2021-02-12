import { getColorSquareDataUriFromModelId } from 'lib/images'

import error_ from 'lib/error'

export default Backbone.Model.extend({
  initialize (attrs) {
    const { name } = attrs

    if (name == null) throw error_.new('invalid shelf', 500, attrs)

    this.set({
      pathname: `/shelves/${attrs._id}`,
      type: 'shelf'
    })

    if (this.get('picture') == null) {
      this.set('picture', getColorSquareDataUriFromModelId(this.get('_id')))
    }

    // The listing is only known for the main user's shelves
    const shelfListing = this.get('listing')
    if (shelfListing != null) {
      const listingKeys = app.user.listings.data[shelfListing]
      this.set({
        icon: listingKeys.icon,
        label: listingKeys.label
      })
    }
  },

  updateMetadata () {
    return {
      title: this.get('name'),
      description: this.get('description'),
      image: this.get('picture'),
      url: this.get('pathname')
    }
  }
})
// TODO: implement shelves RSS feeds server-side
// rss: @getRss()
