import app from '#app/app'
import AlertBox from '#behaviors/alert_box'
import ElasticTextarea from '#behaviors/elastic_textarea'
import General from '#behaviors/general'
import SuccessCheck from '#behaviors/success_check'
import { catchAlert } from '#general/lib/forms'
import { isNonEmptyString } from '#lib/boolean_tests'
import error_ from '#lib/error'
import { getActionKey } from '#lib/key_events'
import log_ from '#lib/loggers'
import { tryAsync } from '#lib/promises'
import confirmationModalTemplate from './templates/confirmation_modal.hbs'
import '../scss/confirmation_modal.scss'

export default Marionette.View.extend({
  className: 'confirmationModal',
  template: confirmationModalTemplate,
  behaviors: {
    AlertBox,
    ElasticTextarea,
    General,
    SuccessCheck,
  },

  ui: {
    no: '#no',
    yes: '#yes',
  },

  serializeData () {
    const data = this.options
    if (!data.yes) data.yes = 'yes'
    if (!data.no) data.no = 'no'
    if (!data.yesButtonClass) data.yesButtonClass = 'alert'
    data.canGoBack = (this.options.back != null)
    return data
  },

  events: {
    'click a#yes': 'yes',
    'click a#no': 'close',
    keydown: 'changeButton',
    'click a#back': 'back',
  },

  onRender () {
    app.execute('modal:open', null, this.options.focus)
    // leave the focus on textarea, if there is one
    if (this.$el.find('#confirmationForm')) { return }
    // trigger once the modal is done sliding down
    this.setTimeout(this.ui.no.focus.bind(this.ui.no), 600)
  },

  yes () {
    const { action, selector } = this.options
    return tryAsync(this.executeFormAction.bind(this))
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
    catchAlert(this, err)
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
    // do not trigger keys if a textarea is shown
    if (this.$el.find('#confirmationForm')) { return }
    if (key === 'left') this.ui.no.focus()
    else if (key === 'right') this.ui.yes.focus()
  },

  back () { this.options.back() },
})
