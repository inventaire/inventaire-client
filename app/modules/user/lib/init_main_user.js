import { parseBooleanString } from 'lib/utils'
import fetchData from 'lib/data/fetch'
import MainUser from '../models/main_user'
import cookie_ from 'js-cookie'

export default function (app) {
  // the cookie is deleted on logout
  const loggedIn = parseBooleanString(cookie_.get('loggedIn'))

  fetchData({
    name: 'user',
    Collection: MainUser,
    condition: loggedIn
  })
  .catch(resetSession)

  app.user.loggedIn = loggedIn
}

// Known cases of session errors:
// - when the server secret is changed
// - when the current session user was deleted but the cookies weren't removed
//   (possibly because the deletion was done from another browser or even another device)
const resetSession = err => {
  console.error('resetSession', err)
  app.execute('logout', '/login')
}
