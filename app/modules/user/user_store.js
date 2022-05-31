// A readable Svelte store that stays in sync with the global app.user Backbone model
import { readable } from 'svelte/store'
import app from '#app/app'

export const user = readable(app.user.attributes, set => {
  const update = () => set(app.user.attributes)
  app.user.on('change', update)
  return () => app.user.off('change', update)
})
