module.exports = class SuccessCheck extends Marionette.Behavior
  ui:
    check: ".check"

  events:
    "check": "showSuccessCheck"
    "fail": "showFail"

  showSuccessCheck: (e, cb)-> @showSignal e, cb, 'check-circle'
  showFail: (e, cb)-> @showSignal e, cb, 'times-circle'

  showSignal: (e, cb, signal)->
    $check = $(e.target).find('.check')
    $check.html "<i class='fa fa-#{signal} text-center'></i>"
    .slideDown(300)

    afterTimeout = ->
      $check.slideUp()
      cb() if cb?

    setTimeout afterTimeout, 600