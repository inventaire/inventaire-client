import error_ from '#lib/error'

// Keep in sync with app/modules/general/scss/_media_query_thresholds.scss
const wellknownWidths = {
  '$small-screen': 1000,
  '$smaller-screen': 600,
  '$very-small-screen': 400,
}
const resolveWidth = width => wellknownWidths[width] ? wellknownWidths[width] : width

// window.visualViewport is being polyfilled (see app/init_polyfills.js)
// but errors can still be found in the logs
export const getViewportWidth = () => window.visualViewport?.width || window.screen.width
export const getViewportHeight = () => window.visualViewport?.height || window.screen.height

export const viewportIsSmallerThan = maxWidth => getViewportWidth() < resolveWidth(maxWidth)
export const viewportIsLargerThan = maxWidth => getViewportWidth() >= resolveWidth(maxWidth)

export const viewportIsSmall = () => viewportIsSmallerThan('$small-screen')

// Scroll to the top of an $el
// Increase marginTop to scroll to a point before the element top
export function scrollToElementTop ({ $el, duration = 500, marginTop = 0, delay = 100 }) {
  if (!($el instanceof $)) {
    throw error_.new('expected jquery $el', 500, arguments)
  }
  const scroll = function () {
    const top = $el.position().top - marginTop
    return $('html, body').animate({ scrollTop: top }, duration)
  }
  return setTimeout(scroll, delay)
}

export function scrollToElement (element, options = {}) {
  if (!(element instanceof HTMLElement)) {
    error_.report('invalid element', { element, options })
    // Assumes that a failing scroll is never worth crashing the calling function
    return
  }

  const { marginTop = 0, waitForRoomToScroll = true } = options

  let attempts = 0
  const attemptToScroll = () => {
    const offset = element.offsetTop
    const viewportHeight = getViewportHeight()
    const bodyHeight = window.document.body.clientHeight
    const hasRoomToScroll = (viewportHeight + offset < bodyHeight)
    if (!waitForRoomToScroll || hasRoomToScroll || ++attempts > 10) {
      window.scrollTo({
        top: Math.max(0, offset - marginTop),
        behavior: 'smooth'
      })
    } else {
      setTimeout(attemptToScroll, 50)
    }
  }

  setTimeout(attemptToScroll, 50)
}
