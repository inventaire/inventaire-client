getActionKey = require 'lib/get_action_key'
error_ = require 'lib/error'

module.exports = Marionette.Behavior.extend
  events:
    'alert': 'showAlertBox'
    'hideAlertBox': 'hideAlertBoxOnly'
    'click a.alert-close': 'hideAlertBoxOnly'
    'keydown': 'hideAlertBox'
    'click .button': 'hideAlertBox'

  # alert-box will be appended to has-alertbox parent
  # OR to the selector parent if a selector is provided in params
  showAlertBox: (e, params)->
    { message, selector } = params
    unless message?
      _.error params, 'couldnt display the alertbox with those params'
      return

    selector or= '.has-alertbox'

    unless /\.|#/.test selector then error_.report 'invalid selector', { selector }
    $target = @$el.find selector

    if $target.length isnt 1
      return _.warn $target, 'alertbox: failed to find single target'

    box = "<div class='alert hidden alert-box'>
          <span class='alert-message'>#{message}</span>
          <a class='alert-close'>&#215;</a>
          </div>"

    $parent = $target.parent()
    # remove the previously added '.alert-box'
    $parent.find('.alert-box').remove()
    $parent.append(box)
    $parent.find('.alert-box').slideDown(500)
    @_showAlertTimestamp = Date.now()

    e.stopPropagation()

  hideAlertBoxOnly: (e)->
    @hideAlertBox e
    e.stopPropagation()

  hideAlertBox: (e)->
    key = getActionKey e
    # Do not close the alert box on 'Ctrl' or 'Shift' especially,
    # as it prevent from opening a possible link in the alert box in a special way
    # If the key is not a special key, key should be undefined
    # and the alertbox will be closde
    if key? and key isnt 'esc' then return

    # Don't hide alert box if it has been visible for less than 1s
    if @_showAlertTimestamp? and not _.expired(@_showAlertTimestamp, 1000) then return

    @$el.find('.alert-box').hide()

    # NB: Do not call 'e.stopPropagation()' as events such as 'click .button' might
    # need to propagate to other event listeners
    # Known case: modules/inventory/views/form/item_creation 'click #transaction'
