module.exports = class SuccessCheck extends Marionette.Behavior
  ui:
    check: ".check"

  events:
    "check": "showSuccessCheck"

  showSuccessCheck: (e, cb)->
    _.log 'CHECK!'
    @ui.check
    .html "<i class='fa fa-check-circle text-center'></i>"
    .slideDown(300)
    setTimeout cb, 600