import log_ from 'lib/loggers'
import { shortLang, deepClone } from 'lib/utils'
import accountSettingsTemplate from './templates/account_settings.hbs'

import { i18n } from 'modules/user/lib/i18n'
import preq from 'lib/preq'
import email_ from 'modules/user/lib/email_tests'
import password_ from 'modules/user/lib/password_tests'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { languages as activeLanguages } from 'lib/active_languages'
import { testAttribute, pickerData } from '../lib/helpers'

export default Marionette.ItemView.extend({
  template: accountSettingsTemplate,
  className: 'accountSettings',
  behaviors: {
    AlertBox: {},
    SuccessCheck: {},
    Loading: {},
    TogglePassword: {}
  },

  ui: {
    email: '#emailField',
    currentPassword: '#currentPassword',
    newPassword: '#newPassword',
    passwords: '.password',
    passwordUpdater: '#passwordUpdater',
    languagePicker: '#languagePicker'
  },

  initialize () {
    return _.extend(this, behaviorsPlugin)
  },

  serializeData () {
    const attrs = this.model.toJSON()
    return _.extend(attrs, {
      emailPicker: this.emailPickerData(),
      languages: log_.info(this.languagesData(), 'languagesData')
    })
  },

  emailPickerData () { return pickerData(this.model, 'email') },

  languagesData () {
    const languages = deepClone(activeLanguages)
    const currentLanguage = shortLang(this.model.get('language'))
    if (languages[currentLanguage] != null) {
      languages[currentLanguage].selected = true
    }
    return languages
  },

  events: {
    'click a#emailButton': 'updateEmail',
    'click a#emailConfirmationRequest': 'emailConfirmationRequest',
    'change select#languagePicker': 'changeLanguage',
    'click a#updatePassword': 'updatePassword',
    'click #forgotPassword' () { app.execute('show:forgot:password') },
    'click #deleteAccount': 'askDeleteAccountConfirmation'
  },

  // EMAIL

  updateEmail () {
    const email = this.ui.email.val()
    return Promise.try(this.testEmail.bind(this, email))
    .then(this.startLoading.bind(this, '#emailButton'))
    .then(email_.verifyAvailability.bind(null, email, '#emailField'))
    .then(this.sendEmailRequest.bind(this, email))
    .then(this.showConfirmationEmailSuccessMessage.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(this.hardStopLoading.bind(this))
  },

  testEmail (email) {
    return testAttribute('email', email, email_)
  },

  sendEmailRequest (email) {
    return preq.get(app.API.auth.emailAvailability(email))
    .get('email')
    .then(this.sendEmailChangeRequest)
  },

  sendEmailChangeRequest (email) {
    return app.request('user:update', {
      attribute: 'email',
      value: email,
      selector: '#emailField'
    }
    )
  },

  hardStopLoading () {
    // triggering stopLoading wasnt working
    // temporary solution
    this.$el.find('.loading').empty()
  },

  // EMAIL CONFIRMATION
  emailConfirmationRequest () {
    $('#notValidEmail').fadeOut()
    return app.request('email:confirmation:request')
    .then(this.showConfirmationEmailSuccessMessage)
  },

  showConfirmationEmailSuccessMessage () {
    $('#confirmationEmailSent').fadeIn()
    return $('#emailButton').once('click', this.hideConfirmationEmailSent)
  },

  hideConfirmationEmailSent () {
    return $('#confirmationEmailSent').fadeOut()
  },

  // PASSWORD

  updatePassword () {
    const currentPassword = this.ui.currentPassword.val()
    const newPassword = this.ui.newPassword.val()

    return Promise.try(() => password_.pass(currentPassword, '#currentPasswordAlert'))
    .then(() => password_.pass(newPassword, '#newPasswordAlert'))
    .then(this.startLoading.bind(this, '#updatePassword'))
    .then(this.confirmCurrentPassword.bind(this, currentPassword))
    .then(this.updateUserPassword.bind(this, currentPassword, newPassword))
    .then(this.ifViewIsIntact('passwordSuccessCheck'))
    .catch(this.ifViewIsIntact('passwordFail'))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(this.stopLoading.bind(this))
  },

  confirmCurrentPassword (currentPassword) {
    return app.request('password:confirmation', currentPassword)
    .catch(err => {
      if (err.statusCode === 401) {
        err = error_.new('wrong password', 400)
        err.selector = '#currentPasswordAlert'
        throw err
      } else { throw err }
    })
  },

  updateUserPassword (currentPassword, newPassword) {
    return app.request('password:update', currentPassword, newPassword)
  },

  passwordSuccessCheck () {
    this.ui.passwords.val('')
    this.ui.passwordUpdater.trigger('check')
  },

  passwordFail (err) {
    this.ui.passwordUpdater.trigger('fail')
    throw err
  },

  // LANGUAGE
  changeLanguage (e) {
    return app.request('user:update', {
      attribute: 'language',
      value: e.target.value,
      selector: '#languagePicker'
    }
    )
  },

  // DELETE ACCOUNT
  askDeleteAccountConfirmation () {
    const args = { username: this.model.get('username') }
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_account_confirmation', args),
      warningText: i18n('cant_undo_warning'),
      action: this.model.deleteAccount.bind(this.model),
      selector: '#usernameGroup',
      formAction: sendDeletionFeedback,
      formLabel: "that would really help us if you could say a few words about why you're leaving:",
      formPlaceholder: "our love wasn't possible because",
      yes: 'delete your account',
      no: 'cancel'
    }
    )
  }
})

const sendDeletionFeedback = message => preq.post(app.API.feedback, {
  subject: '[account deletion]',
  message
}
)
