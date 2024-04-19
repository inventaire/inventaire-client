import { API } from '#app/api/api'
import { localStorageProxy } from '#app/lib/local_storage'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'

export default redirect => {
  preq.post(API.auth.logout)
  .then(logoutSuccess(redirect))
  .catch(log_.Error('logout error'))
}

const logoutSuccess = redirect => function () {
  // Clearing localstorage
  localStorageProxy.clear()
  log_.info('You have been successfully logged out')
  // Default to redirecting home
  window.location.href = redirect || '/'
}
