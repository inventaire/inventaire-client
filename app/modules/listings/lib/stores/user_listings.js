import { getListingsByCreators } from '#listings/lib/listings'
import { writable } from 'svelte/store'
const noop = () => {}

export const userListings = writable([], start)

function start (setStoreValue) {
  refresh(setStoreValue)
  const stop = noop
  return stop
}

async function refresh (setStoreValue) {
  if (app.user.loggedIn) {
    const { listings } = await getListingsByCreators({ usersIds: app.user.id })
    setStoreValue(listings)
  } else {
    setStoreValue([])
  }
}

userListings.refresh = refresh
