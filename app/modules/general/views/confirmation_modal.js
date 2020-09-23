import getActionKey from 'lib/get_action_key'
import error_ from 'lib/error'
import forms_ from 'modules/general/lib/forms'

export default Marionette.ItemView.extend({
  className: 'confirmationModal',
  template: require('./templates/confirmation_modal'),
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
    return this.setTimeout(this.ui.no.focus.bind(this.ui.no), 600)
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
    _.error(err, 'confirmation action err')
    this.$el.trigger('fail')
    error_.complete(err, '.check', false)
    return forms_.catchAlert(this, err)
  },

  close () {
    if (this.options.back != null) {
      return this.options.back()
    } else { return app.execute('modal:close') }
  },

  stopLoading (selector) {
    if (selector != null) {
      return $(selector).trigger('stopLoading')
    } else { return _.warn('confirmation modal: no selector was provided') }
  },

  executeFormAction () {
    const { formAction } = this.options
    if (formAction != null) {
      const formContent = this.$el.find('#confirmationForm').val()
      if (_.isNonEmptyString(formContent)) {
        return formAction(formContent)
      }
    }
  },

  changeButton (e) {
    const key = getActionKey(e)
    switch (key) {
    case 'left': return this.ui.no.focus()
    case 'right': return this.ui.yes.focus()
    }
  },

  back () { return this.options.back() }
})
