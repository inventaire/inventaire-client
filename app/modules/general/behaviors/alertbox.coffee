module.exports = class AlertBox extends Marionette.Behavior
  ui:
    hasAlertbox: ".has-alertbox"

  events:
    'alert': 'showAlertBox'
    'hideAlertBox': 'hideAlertBox'
    'keydown': 'hideAlertBox'
    'click a.close': 'hideAlertBox'
    'click .button': 'hideAlertBox'


  showAlertBox: (e, params)->
    if params.message?
      if params.selector?
        $target = $(params.selector)
      else
        $target = @ui.hasAlertbox
      box = "<div class='alert hidden alert-box'>#{params.message}
        <a class='close'>&times;</a>
        </div>"
      $parent = $target.parent()
      # remove the previously added '.alert-box'
      $parent.find('.alert-box').remove()
      $parent.append(box)
      $parent.find('.alert-box').slideDown(200)
    else
      _.log params, 'couldnt display the alertbox with those params'

  hideAlertBox: ->
    @$el.find('.alert-box').hide()