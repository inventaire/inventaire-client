import { readable } from 'svelte/store'
import app from '#app/app'
import initMainUser from '#user/lib/init_main_user'

initMainUser(app)

// A readable Svelte store that stays in sync with the global app.user Backbone model
export const user = readable(app.user.attributes, set => {
  const update = () => set(app.user.attributes)
  app.user.on('confirmed', update)
  return () => app.user.off('confirmed', update)
})
