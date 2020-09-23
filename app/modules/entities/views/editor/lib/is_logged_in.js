/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default function () {
  if (app.user.loggedIn) {
    return true
  } else {
    const msg = 'you need to be connected to edit this page'
    app.execute('show:call:to:connection', msg)
    return false
  }
};
