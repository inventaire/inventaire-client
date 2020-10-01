import preq from 'lib/preq'

export default redirect => {
  preq.post(app.API.auth.logout)
  .then(logoutSuccess(redirect))
  .catch(_.Error('logout error'))
}

const logoutSuccess = redirect => function (data) {
  deleteLocalDatabases()
  _.log('You have been successfully logged out')
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
