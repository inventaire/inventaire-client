import preq from '#lib/preq'
let intervalId = null
let active = false

export default function () {
  const showNetworkError = () => {
    if (active) return
    active = true
    this.ui.flashMessage.addClass('active')
    if (intervalId == null) intervalId = setInterval(checkState, 1000)
  }

  const hideNetworkError = () => {
    if (!active) return
    active = false
    this.ui.flashMessage.removeClass('active')
    if (intervalId != null) {
      clearInterval(intervalId)
      intervalId = null
    }
  }

  const checkState = () => preq.get(app.API.tests).then(hideNetworkError)

  app.commands.setHandlers({
    'flash:message:show:network:error': showNetworkError
  })
}
