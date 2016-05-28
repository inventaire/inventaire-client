module.exports = ->
  if app.user.loggedIn then return true
  else
    msg = 'you need to be connected to edit this page'
    app.execute 'show:call:to:connection', msg
    return false