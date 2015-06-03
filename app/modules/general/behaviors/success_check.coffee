module.exports = Marionette.Behavior.extend
  events:
    'check': 'showSuccessCheck'
    'fail': 'showFail'

  showSuccessCheck: (e, cb)-> @showSignal e, cb, 'check-circle'
  showFail: (e, cb)-> @showSignal e, cb, 'times-circle'

  showSignal: (e, cb, signal)->
    # cant use the View ui object as there might be several nodes with
    # the .check class
    $wrapper = $(e.target).parents('.checkWrapper')
    if $wrapper.length is 1
      $check = $wrapper.find('.check')
    else
      console.warn 'deprecated success check form: please use .checkWrapper format'
      $check = $(e.target).find('.check')

    $check.hide().html "<i class='fa fa-#{signal} text-center'></i>"
    .slideDown(300)

    afterTimeout = ->
      $check.slideUp()
      cb() if cb?

    setTimeout afterTimeout, 600
