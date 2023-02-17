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

export default {
  isSmall (ceil = wellknownWidths['$small-screen']) {
    return getViewportWidth() < ceil
  },

  // Scroll to the top of an $el
  // Increase marginTop to scroll to a point before the element top
  scrollTop ($el, duration, marginTop, delay) {
    if (_.isObject($el) && !($el instanceof $)) {
      ({ $el, duration, marginTop, delay } = $el)
    }

    // Polymorphism: accept jquery objects or selector strings as $el
    if (_.isString($el)) $el = $($el)

    if (duration == null) duration = 500
    if (marginTop == null) marginTop = 0
    if (delay == null) delay = 100

    const scroll = function () {
      const top = $el.position().top - marginTop
      return $('html, body').animate({ scrollTop: top }, duration)
    }
    return setTimeout(scroll, delay)
  },

  // Scroll to a given height
  scrollHeight (height, ms = 500) {
    return $('html, body').animate({ scrollTop: height }, ms)
  },

  // Scroll to the top of an element inside a element with a scroll,
  // typically a list of search results partially hidden
  innerScrollTop ($parent, $children) {
    let scrollTop
    if ($children?.length > 0) {
      const selectedTop = $children.position().top
      // Adjust scroll to the selected element
      scrollTop = ($parent.scrollTop() + selectedTop) - 50
    } else {
      scrollTop = 0
    }
    return $parent.animate({ scrollTop }, { duration: 50, easing: 'swing' })
  },

  scrollToElement (element, options = {}) {
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
}
