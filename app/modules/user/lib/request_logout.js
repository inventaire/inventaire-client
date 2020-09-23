/* eslint-disable
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default redirect => _.preq.post(app.API.auth.logout)
.then(logoutSuccess(redirect))
.catch(_.Error('logout error'))

var logoutSuccess = redirect => function (data) {
  deleteLocalDatabases()
  _.log('You have been successfully logged out')
  // Default to redirecting home
  return window.location.href = redirect || '/'
}

var deleteLocalDatabases = function () {
  const debug = localStorageProxy.getItem('debug')
  // Clearing localstorage
  localStorageProxy.clear()
  // but keeping debug config
  return localStorageProxy.setItem('debug', debug)
}
