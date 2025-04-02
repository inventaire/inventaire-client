import { writable } from 'svelte/store'
import { getListingsByCreators } from '#listings/lib/listings'
import { mainUser } from '#user/lib/main_user'

const noop = () => {}

function start (setStoreValue) {
  refresh(setStoreValue)
  const stop = noop
  return stop
}

async function refresh (setStoreValue) {
  if (mainUser.loggedIn) {
    const { listings } = await getListingsByCreators({ usersIds: [ mainUser._id ] })
    setStoreValue(listings)
  } else {
    setStoreValue([])
  }
}

export const userListings = Object.assign(writable([], start), { refresh })
