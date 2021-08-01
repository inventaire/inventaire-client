// A readable Svelte store that stays in sync with the global app.user Backbone model
import { readable } from 'svelte/store'
import app from 'app/app'

export const user = readable(app.user.attributes, set => {
  app.user.on('change', () => set(app.user.attributes))
})
