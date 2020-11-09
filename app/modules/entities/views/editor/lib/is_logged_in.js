export default function () {
  if (app.user.loggedIn) {
    return true
  } else {
    const msg = 'you need to be connected to edit this page'
    app.execute('show:call:to:connection', msg)
    return false
  }
}
