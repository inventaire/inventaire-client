module.exports =
  loggedIn: (options)-> if app.user.loggedIn then options.fn @
  notLoggedIn: (options)-> unless app.user.loggedIn then options.fn @
