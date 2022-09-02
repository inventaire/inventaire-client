// A readable Svelte store that stays in sync with the global app.user Backbone model
import { readable } from 'svelte/store'
import app from '#app/app'

// The start function can not be async as it is supposed to return a stop function
// and not a promise (see https://github.com/sveltejs/svelte/issues/4765#issuecomment-623092644=)
export const userGroups = readable([], set => {
  const stopFnPromise = init(set)
  return async () => {
    const stopFn = await stopFnPromise
    stopFn()
  }
})

const init = async set => {
  await app.request('wait:for', 'groups')
  const update = () => set(app.groups.map(model => model.toJSON()))
  update()
  app.groups.on('add', update)
  app.groups.on('remove', update)
  return () => {
    app.groups.off('add', update)
    app.groups.off('remove', update)
  }
}
