import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { newError } from '#app/lib/error'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { getListingMetadata, getListingPathname, getListingWithElementsById, getElementPathname, getElementMetadata, assignEntitiesToElements } from '#listings/lib/listings'
import { getElementById } from '#modules/listings/lib/listings'
import type { ListingElement } from '#server/types/element'
import type { ListingWithElements } from '#server/types/listing'
import { mainUser } from '#user/lib/main_user'
import type { SerializedUser } from '#users/lib/users'
import { showUserListings } from '#users/users'
import { getSerializedUser } from '#users/users_data'

export default {
  initialize () {
    addRoutes({
      '/lists/:id/element/:elementId(/)': 'showElement',
      '/lists/:id(/)': 'showListing',
      '/lists(/)': 'showMainUserListings',
    }, controller)
  },
}

interface ListingProps {
  listing: ListingWithElements
  initialElement?: ListingElement
  creator: SerializedUser
}

async function showListing (listingId) {
  try {
    const [
      { default: ListingLayout },
      { listing },
    ] = await Promise.all([
      import('./components/listing_layout.svelte'),
      getListingWithElementsById(listingId),
    ])
    const { creator: creatorId } = listing
    const creator = await getSerializedUser(creatorId)
    const props: ListingProps = { listing, creator }
    appLayout.showChildComponent('main', ListingLayout, { props })
    app.navigate(getListingPathname(listing._id), { metadata: getListingMetadata(listing) })
  } catch (err) {
    commands.execute('show:error', err)
  }
}

async function showElement (listingId, elementId) {
  const { default: ListingLayout } = await import('./components/listing_layout.svelte')
  try {
    const { element } = await getElementById(elementId)
    if (!element) throw newError(`could not find element ${elementId}`)

    const { listing } = await getListingWithElementsById(element.list)
    if (!listing) throw newError(`could not find listing ${element.list}`)

    const { creator: creatorId } = listing
    const creator = await getSerializedUser(creatorId)

    const props: ListingProps = { listing, creator }
    await assignEntitiesToElements([ element ])
    props.initialElement = element

    appLayout.showChildComponent('main', ListingLayout, { props })
    app.navigate(getElementPathname(listing._id, elementId), {
      metadata: getElementMetadata(listing, element),
    })
  } catch (err) {
    commands.execute('show:error', err)
  }
}

export async function showMainUserListings () {
  if (mainUser.loggedIn) {
    return showUserListings(mainUser.username)
  } else {
    reqres.request('require:loggedIn', 'lists')
  }
}

const controller = {
  showListing,
  showElement,
  showUserListings,
  showMainUserListings,
} as const
