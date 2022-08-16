// A readable Svelte store that stays in sync with the global app.user Backbone model
import { readable } from 'svelte/store'
import app from '#app/app'

export const userGroups = readable([], start)

// The start function can not be async as it is supposed to return a stop function
// and not a promise (see https://github.com/sveltejs/svelte/issues/4765#issuecomment-623092644=)
function start (setStoreValue) {
  const update = async () => {
    await app.request('wait:for', 'groups')
    const updateStoreValue = app.groups.map(model => model.toJSON())
    setStoreValue(updateStoreValue)
  }

  app.groups.on('add', update)
  app.groups.on('remove', update)

  // Call immediately, in case app.groups was populated
  // before this start was called
  update()

  const stop = () => {
    app.groups.off('add', update)
    app.groups.off('remove', update)
  }

  return stop
}
