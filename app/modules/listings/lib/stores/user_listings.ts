import { writable } from 'svelte/store'
import app from '#app/app'
import { getListingsByCreators } from '#listings/lib/listings'

const noop = () => {}

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

export const userListings = Object.assign(writable([], start), { refresh })
