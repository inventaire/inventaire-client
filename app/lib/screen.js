/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let screen_

export default screen_ = {
  // /!\ window.screen.width is the screen's width not the current window width
  width () { return $(window).width() },
  height () { return $(window).height() },
  // keep in sync with app/modules/general/scss/_grid_and_media_query_ranges.scss
  isSmall (ceil = 1000) { return screen_.width() < ceil },

  // Scroll to the top of an $el
  // Increase marginTop to scroll to a point before the element top
  scrollTop ($el, duration, marginTop, delay) {
    if (_.isObject($el) && !($el instanceof $)) {
      ({ $el, duration, marginTop, delay } = $el)
    }

    // Polymorphism: accept jquery objects or selector strings as $el
    if (_.isString($el)) { $el = $($el) }

    if (duration == null) { duration = 500 }
    if (marginTop == null) { marginTop = 0 }
    if (delay == null) { delay = 100 }

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
  }
}
