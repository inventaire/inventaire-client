import app from '#app/app'
import { newError } from '#app/lib/error'
import { getListingMetadata, getListingPathname, getListingWithElementsById, getElementPathname, getElementMetadata, assignEntitiesToElements } from '#listings/lib/listings'
import { getElementById } from '#modules/listings/lib/listings'
import type { ListingElement } from '#server/types/element'
import type { ListingWithElements } from '#server/types/listing'
import { showUserListings } from '#users/users'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists/(:id)/element/(:elementId)(/)': 'showElement',
        'lists/(:id)(/)': 'showListing',
        'lists(/)': 'showMainUserListings',
      },
    })

    new Router({ controller })
  },
}

interface ListingProps {
  initialElement?: ListingElement
  listing: ListingWithElements
}

async function showListing (listingId) {
  const { default: ListingLayout } = await import('./components/listing_layout.svelte')
  try {
    const { listing } = await getListingWithElementsById(listingId)
    const props: ListingProps = { listing }
    app.layout.showChildComponent('main', ListingLayout, { props })
    app.navigate(getListingPathname(listing._id), { metadata: getListingMetadata(listing) })
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showElement (listingId, elementId) {
  const { default: ListingLayout } = await import('./components/listing_layout.svelte')
  try {
    const { element } = await getElementById(elementId)
    if (!element) throw newError(`could not find element ${elementId}`)

    const { listing } = await getListingWithElementsById(element.list)
    if (!listing) throw newError(`could not find listing ${element.list}`)

    const props: ListingProps = { listing }
    await assignEntitiesToElements([ element ])
    props.initialElement = element

    app.layout.showChildComponent('main', ListingLayout, { props })
    app.navigate(getElementPathname(listing._id, elementId), { metadata: getElementMetadata(listing, element) })
  } catch (err) {
    app.execute('show:error', err)
  }
}

export async function showMainUserListings () {
  return showUserListings(app.user.get('username'))
}

const controller = {
  showListing,
  showElement,
  showUserListings,
  showMainUserListings,
}
