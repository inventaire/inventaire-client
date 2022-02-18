import log_ from '#lib/loggers'
import { expired } from '#lib/utils'
import getActionKey from '#lib/get_action_key'
import error_ from '#lib/error'
import { I18n } from '#user/lib/i18n'
import Handlebars from 'handlebars/runtime'
const { escapeExpression } = Handlebars

export default Marionette.Behavior.extend({
  behaviorName: 'AlertBox',

  events: {
    alert: 'showAlertBox',
    hideAlertBox: 'hideAlertBoxOnly',
    'click .alert-close': 'hideAlertBoxOnly',
    keydown: 'hideAlertBox',
    'click .button': 'hideAlertBox'
  },

  // alert-box will be appended to has-alertbox parent
  // OR to the selector parent if a selector is provided in params
  showAlertBox (e, params) {
    let { message, selector } = params
    if (message == null) {
      log_.error(params, 'couldnt display the alertbox with those params')
      return
    }

    if (!selector) selector = '.has-alertbox'

    if (!/\.|#/.test(selector)) error_.report('invalid selector', { selector })
    const $target = this.$el.find(selector)

    if ($target.length !== 1) {
      return log_.warn($target, 'alertbox: failed to find single target')
    }

    const box = `<div class="alert hidden alert-box" role="alert"> \
<span class="alert-message">${escapeExpression(message)}</span> \
<button title="${I18n('close')}" class="alert-close" aria-label="${I18n('close')}">&#215;</button> \
</div>`

    const $parent = $target.parent()
    // remove the previously added '.alert-box'
    $parent.find('.alert-box').remove()
    $parent.append(box)
    $parent.find('.alert-box').slideDown(500)
    this._showAlertTimestamp = Date.now()

    e.stopPropagation()
  },

  hideAlertBoxOnly (e) {
    this.hideAlertBox(e)
    e.stopPropagation()
  },

  hideAlertBox (e) {
    const key = getActionKey(e)
    // Do not close the alert box on 'Ctrl' or 'Shift' especially,
    // as it prevent from opening a possible link in the alert box in a special way
    // If the key is not a special key, key should be undefined
    // and the alertbox will be closde
    if ((key != null) && (key !== 'esc')) return

    // Don't hide alert box if it has been visible for less than 1s
    if ((this._showAlertTimestamp != null) && !expired(this._showAlertTimestamp, 1000)) return

    this.$el.find('.alert-box').hide()
  }
})

// NB: Do not call 'e.stopPropagation()' as events such as 'click .button' might
// need to propagate to other event listeners
// Known case: modules/inventory/views/form/item_creation 'click #transaction'
