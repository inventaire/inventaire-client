import log_ from 'lib/loggers'
import preq from 'lib/preq'

export default redirect => {
  preq.post(app.API.auth.logout)
  .then(logoutSuccess(redirect))
  .catch(log_.Error('logout error'))
}

const logoutSuccess = redirect => function (data) {
  deleteLocalDatabases()
  log_.info('You have been successfully logged out')
  // Default to redirecting home
  window.location.href = redirect || '/'
}

const deleteLocalDatabases = function () {
  const debug = localStorageProxy.getItem('debug')
  // Clearing localstorage
  localStorageProxy.clear()
  // but keeping debug config
  localStorageProxy.setItem('debug', debug)
}
