{ currentRoute } = require 'lib/location'
routeAllowlist = [
  'signup'
  'login'
  'login/reset-password'
]

module.exports = (e)->
  # Allow submit on singup and login to let password managers react to the submit event
  if currentRoute() in routeAllowlist then return
  e.preventDefault()
