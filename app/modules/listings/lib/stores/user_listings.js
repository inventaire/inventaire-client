import preq from '#lib/preq'
import { writable } from 'svelte/store'
const noop = () => {}

export const userListings = writable([], start)

function start (setStoreValue) {
  refresh(setStoreValue)
  const stop = noop
  return stop
}

async function refresh (setStoreValue) {
  const { lists: listings } = await preq.get(app.API.listings.byCreators(app.user.id))
  setStoreValue(listings)
}

userListings.refresh = refresh
