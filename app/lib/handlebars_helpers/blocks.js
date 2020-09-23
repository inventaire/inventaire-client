/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default {
  loggedIn (options) { if (app.user.loggedIn) { return options.fn(this) } },
  notLoggedIn (options) { if (!app.user.loggedIn) { return options.fn(this) } }
}
