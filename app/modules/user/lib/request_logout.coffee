module.exports = ->
  _.preq.post(app.API.auth.logout)
  .then logoutSuccess
  .catch logoutError

logoutSuccess = (data)->
  deleteLocalDatabases()
  app.execute 'persona:logout:request'
  _.log "You have been successfully logged out"
  window.location.reload()

logoutError = (err)->
  _.error err, 'logout error'

deleteLocalDatabases = ->
  localStorage.clear()
  window.dbs.reset()
