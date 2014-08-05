module.exports = class SuccessCheck extends Marionette.Behavior
  ui:
    check: ".check"

  events:
    "check": "showSuccessCheck"
    "fail": "showFail"

  showSuccessCheck: (e, cb)-> @showSignal cb, 'check-circle'
  showFail: (e, cb)-> @showSignal cb, 'times-circle'

  showSignal: (cb, signal)->
    @ui.check
    .html "<i class='fa fa-#{signal} text-center'></i>"
    .slideDown(300)
    setTimeout cb, 600