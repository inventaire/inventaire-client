import { isNonEmptyString } from 'lib/boolean_tests'
import log_ from 'lib/loggers'
import getActionKey from 'lib/get_action_key'
import error_ from 'lib/error'
import forms_ from 'modules/general/lib/forms'
import confirmationModalTemplate from './templates/confirmation_modal.hbs'

export default Marionette.ItemView.extend({
  className: 'confirmationModal',
  template: confirmationModalTemplate,
  behaviors: {
    SuccessCheck: {},
    AlertBox: {},
    ElasticTextarea: {},
    General: {}
  },

  ui: {
    no: '#no',
    yes: '#yes'
  },

  serializeData () {
    const data = this.options
    if (!data.yes) { data.yes = 'yes' }
    if (!data.no) { data.no = 'no' }
    if (!data.yesButtonClass) { data.yesButtonClass = 'alert' }
    data.canGoBack = (this.options.back != null)
    return data
  },

  events: {
    'click a#yes': 'yes',
    'click a#no': 'close',
    keydown: 'changeButton',
    'click a#back': 'back'
  },

  onShow () {
    app.execute('modal:open', null, this.options.focus)
    // trigger once the modal is done sliding down
    this.setTimeout(this.ui.no.focus.bind(this.ui.no), 600)
  },

  yes () {
    const { action, selector } = this.options
    return Promise.try(this.executeFormAction.bind(this))
    .then(action)
    .then(this.success.bind(this))
    .catch(this.error.bind(this))
    .finally(this.stopLoading.bind(null, selector))
  },

  success (res) {
    this.$el.trigger('check', this.close.bind(this))
    return res
  },

  error (err) {
    log_.error(err, 'confirmation action err')
    this.$el.trigger('fail')
    error_.complete(err, '.check', false)
    forms_.catchAlert(this, err)
  },

  close () {
    if (this.options.back != null) {
      this.options.back()
    } else {
      app.execute('modal:close')
    }
  },

  stopLoading (selector) {
    if (selector != null) {
      $(selector).trigger('stopLoading')
    } else {
      log_.warn('confirmation modal: no selector was provided')
    }
  },

  executeFormAction () {
    const { formAction } = this.options
    if (formAction != null) {
      const formContent = this.$el.find('#confirmationForm').val()
      if (isNonEmptyString(formContent)) formAction(formContent)
    }
  },

  changeButton (e) {
    const key = getActionKey(e)
    if (key === 'left') this.ui.no.focus()
    else if (key === 'right') this.ui.yes.focus()
  },

  back () { this.options.back() }
})
