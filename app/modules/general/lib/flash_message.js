/* eslint-disable
    no-return-assign,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let intervalId = null
let active = false

export default function () {
  const showNetworkError = () => {
    if (active) { return }
    active = true
    this.ui.flashMessage.addClass('active')
    if (intervalId == null) { return intervalId = setInterval(checkState, 1000) }
  }

  const hideNetworkError = () => {
    if (!active) { return }
    active = false
    this.ui.flashMessage.removeClass('active')
    if (intervalId != null) {
      clearInterval(intervalId)
      return intervalId = null
    }
  }

  var checkState = () => _.preq.get(app.API.tests)
  .then(hideNetworkError)

  return app.commands.setHandlers({ 'flash:message:show:network:error': showNetworkError })
};
