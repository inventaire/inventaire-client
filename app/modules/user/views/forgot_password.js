/* eslint-disable
    implicit-arrow-linebreak,
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import email_ from 'modules/user/lib/email_tests'
import forms_ from 'modules/general/lib/forms'
import behaviorsPlugin from 'modules/general/plugins/behaviors'

export default Marionette.ItemView.extend({
  className: 'authMenu login',
  template: require('./templates/forgot_password'),
  behaviors: {
    AlertBox: {},
    SuccessCheck: {},
    Loading: {}
  },

  ui: {
    email: '#emailField',
    confirmationEmailSent: '#confirmationEmailSent'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    return this.lazySendEmail = _.debounce(this.sendEmail.bind(this), 1500, true)
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
    } else { return 'forgot password?' }
  },

  emailPickerData () {
    return {
      nameBase: 'email',
      special: true,
      field: {
        value: app.user.get('email'),
        placeholder: _.i18n('email address')
      },
      button: {
        text: _.i18n('send email'),
        classes: 'grey postfix'
      }
    }
  },

  events () {
    return { 'click a#emailButton': 'lazySendEmail' }
  },

  sendEmail () {
    const email = this.ui.email.val()
    return Promise.try(() => email_.pass(email, '#emailField'))
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
    return this.ui.confirmationEmailSent.fadeIn()
  }
})

var verifyKnownEmail = email => // re-using verifyAvailability but with the opposite expectaction:
// if it throws an error, the email is known and that's the desired result here
// thus the error is catched
  email_.verifyAvailability(email, '#emailField')
.then(unknownEmail)
.catch(err => {
  if (err.statusCode === 400) {
    return 'known email'
  } else { throw err }
})

var unknownEmail = () => formatErr(new Error('this email is unknown'))

var formatErr = function (err) {
  err.selector = '#emailField'
  throw err
}
