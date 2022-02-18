import { tryAsync } from '#lib/promises'
import { i18n } from '#user/lib/i18n'
import email_ from '#user/lib/email_tests'
import forms_ from '#general/lib/forms'
import behaviorsPlugin from '#general/plugins/behaviors'
import forgotPasswordTemplate from './templates/forgot_password.hbs'
import '../scss/auth_menu.scss'
import AlertBox from '#behaviors/alert_box'
import Loading from '#behaviors/loading'
import SuccessCheck from '#behaviors/success_check'

export default Marionette.View.extend({
  className: 'authMenu login',
  template: forgotPasswordTemplate,
  behaviors: {
    AlertBox,
    Loading,
    SuccessCheck,
  },

  ui: {
    email: '#emailField',
    confirmationEmailSent: '#confirmationEmailSent'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
  },

  serializeData () {
    return {
      emailPicker: this.emailPickerData(),
      header: this.headerData()
    }
  },

  headerData () {
    if (this.options.createPasswordMode) {
      return 'create a password'
    } else {
      return 'forgot password?'
    }
  },

  emailPickerData () {
    return {
      nameBase: 'email',
      special: true,
      field: {
        value: app.user.get('email'),
        placeholder: i18n('email address')
      },
      button: {
        text: i18n('send email'),
        classes: 'grey postfix'
      }
    }
  },

  events: {
    'click #emailButton': 'sendEmail'
  },

  sendEmail () {
    const email = this.ui.email.val()
    return tryAsync(() => email_.pass(email, '#emailField'))
    .then(this.startLoading.bind(this, '#emailButton'))
    .then(verifyKnownEmail.bind(null, email))
    .then(this.sendResetPasswordLink.bind(this, email))
    .then(this.showSuccessMessage.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(this.stopLoading.bind(this))
  },

  sendResetPasswordLink (email) {
    return app.request('password:reset:request', email)
    .catch(formatErr)
  },

  showSuccessMessage () {
    this.ui.confirmationEmailSent.removeClass('hidden')
  }
})

// re-using verifyAvailability but with the opposite expectaction:
// if it throws an error, the email is known and that's the desired result here
// thus the error is catched
const verifyKnownEmail = email => {
  return email_.verifyAvailability(email, '#emailField')
  .then(unknownEmail)
  .catch(err => {
    if (err.statusCode === 400) {
      return 'known email'
    } else {
      throw err
    }
  })
}

const unknownEmail = () => formatErr(new Error('this email is unknown'))

const formatErr = function (err) {
  err.selector = '#emailField'
  throw err
}
