module.exports = class AlertBox extends Marionette.Behavior
  ui:
    hasAlertbox: ".has-alertbox"

  events:
    'alert': 'showAlertBox'
    'hideAlertBox': 'hideAlertBox'
    'keydown': 'hideAlertBox'
    'click a.close': 'hideAlertBox'
    'click .button': 'hideAlertBox'


  # alert-box will be appended to has-alertbox parent
  showAlertBox: (e, params)->
    {message, selector} = params
    unless message?
      _.error params, 'couldnt display the alertbox with those params'
      return

    if selector? then $target = $(selector)
    else $target = @ui.hasAlertbox

    box = "<div class='alert hidden alert-box'>#{message}
          <a class='close'>&times;</a>
          </div>"
    $parent = $target.parent()
    # remove the previously added '.alert-box'
    $parent.find('.alert-box').remove()
    $parent.append(box)
    $parent.find('.alert-box').slideDown(200)

  hideAlertBox: ->
    @$el.find('.alert-box').hide()
