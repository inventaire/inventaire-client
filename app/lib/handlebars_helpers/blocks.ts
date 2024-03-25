export default {
  loggedIn (options) { if (app.user.loggedIn) { return options.fn(this) } },
  notLoggedIn (options) { if (!app.user.loggedIn) { return options.fn(this) } },
}
