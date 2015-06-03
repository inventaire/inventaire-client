module.exports = Marionette.Behavior.extend
  ui:
    hasAlertbox: ".has-alertbox"

  events:
    'alert': 'showAlertBox'
    'hideAlertBox': 'hideAlertBox'
    'keydown': 'hideAlertBox'
    'click a.close': 'hideAlertBox'
    'click .button': 'hideAlertBox'


  # alert-box will be appended to has-alertbox parent
  # OR to the selector parent if a selector is provided in params
  showAlertBox: (e, params)->
    {message, selector} = params
    unless message?
      _.error params, 'couldnt display the alertbox with those params'
      return

    if selector?
      unless /\.|#/.test selector
        _.error selector, 'invalid selector'
      $target = $(selector)

    else $target = @ui.hasAlertbox

    box = "<div class='alert hidden alert-box'>#{message}
          <a class='close'>&times;</a>
          </div>"
    $parent = $target.parent()
    # remove the previously added '.alert-box'
    $parent.find('.alert-box').remove()
    $parent.append(box)
    $parent.find('.alert-box').slideDown(500)

  hideAlertBox: ->
    @$el.find('.alert-box').hide()
