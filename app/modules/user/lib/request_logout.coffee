module.exports = (redirect)->
  _.preq.post app.API.auth.logout
  .then logoutSuccess(redirect)
  .catch _.Error('logout error')

logoutSuccess = (redirect)-> (data)->
  deleteLocalDatabases()
  _.log 'You have been successfully logged out'
  # Default to redirecting home
  window.location.href = redirect or '/'

deleteLocalDatabases = ->
  debug = localStorageProxy.getItem 'debug'
  # Clearing localstorage
  localStorageProxy.clear()
  # but keeping debug config
  localStorageProxy.setItem 'debug', debug
