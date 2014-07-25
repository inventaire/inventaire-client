module.exports = class SuccessCheck extends Marionette.Behavior
  ui:
    check: ".check"

  events:
    "check": "showSuccessCheck"

  showSuccessCheck: (e, cb)->
    _.log 'CHECK!'
    @ui.check
    .html "<i class='fa fa-check-circle hidden text-center'></i>"
    .slideDown(400)
    setTimeout cb, 600