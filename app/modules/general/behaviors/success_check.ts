import log_ from '#lib/loggers'
import { icon } from '#lib/icons'

// elements required in the view: .checkWrapper > .check

export default Marionette.Behavior.extend({
  behaviorName: 'SuccessCheck',

  events: {
    check: 'showSuccessCheck',
    fail: 'showFail'
  },

  showSuccessCheck (e, cb) { this.showSignal(e, cb, 'check-circle') },
  showFail (e, cb) { this.showSignal(e, cb, 'times-circle') },

  showSignal (e, cb, signal) {
    // cant use the View ui object as there might be several nodes with
    // the .check class
    let $check
    const $wrapper = $(e.target).parents('.checkWrapper')
    if ($wrapper.length === 1) {
      $check = $wrapper.find('.check')
    // If the target is a .loading element, use it as a check container
    // (allows to work easily with the Loading behavior: replacing the loader once done)
    } else if ($(e.target)[0]?.attributes.class?.value.match(/loading/)) {
      $check = $(e.target)
    } else {
      // console.warn 'deprecated success check form: please use .checkWrapper format'
      $check = $(e.target).find('.check')
    }

    if ($check.length !== 1) {
      return log_.warn($check, '.check target not found')
    }

    $check
    .hide()
    .html(icon(signal, 'text-center'))
    .slideDown(300)

    const afterTimeout = function () {
      $check.slideUp()
      if (cb != null) cb()
    }

    this.view.setTimeout(afterTimeout, 600)
  }
})
