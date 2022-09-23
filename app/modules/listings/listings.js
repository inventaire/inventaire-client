import app from '#app/app'
import { getListingMetadata, getListingPathname, getListingWithElementsById } from './lib/listings.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists/(:id)(/)': 'showListing',
      }
    })

    new Router({ controller: API })
  },
}

async function showListing (listingId) {
  const { default: ListingLayout } = await import('./components/listing_layout.svelte')
  try {
    const { listing } = await getListingWithElementsById(listingId)
    app.layout.showChildComponent('main', ListingLayout, {
      props: { listing }
    })
    app.navigate(getListingPathname(listing._id), { metadata: getListingMetadata(listing) })
  } catch (err) {
    app.execute('show:error', err)
  }
}

const API = {
  showListing,
}
