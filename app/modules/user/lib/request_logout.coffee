module.exports = ->
  _.preq.post(app.API.auth.logout)
  .then logoutSuccess
  .catch logoutError

logoutSuccess = (data)->
  deleteLocalDatabases()
  app.execute 'persona:logout:request'
  _.log "You have been successfully logged out"
  # redirecting home so that it doesn't trigger a route requiring login
  # thus triggering a show:login
  window.location.href = '/'

logoutError = (err)->
  _.error err, 'logout error'

deleteLocalDatabases = ->
  localStorage.clear()
  window.dbs.reset()
