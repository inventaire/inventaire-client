import username_ from 'modules/user/lib/username_tests'
import email_ from 'modules/user/lib/email_tests'
import password_ from 'modules/user/lib/password_tests'
import forms_ from 'modules/general/lib/forms'
import prepareRedirect from '../lib/prepare_redirect'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'

export default Marionette.LayoutView.extend({
  className: 'authMenu signup',
  template: require('./templates/signup_classic.hbs'),
  behaviors: {
    AlertBox: {},
    TogglePassword: {},
    Loading: {}
  },

  ui: {
    classicUsername: '#classicUsername',
    email: '#email',
    suggestionGroup: '#suggestionGroup',
    suggestion: '#suggestion',
    password: '#password'
  },

  initialize () {
    this.formAction = prepareRedirect.call(this)
  },

  events: {
    'blur #classicUsername': 'earlyVerifyClassicUsername',
    'blur #email': 'earlyVerifyEmail',
    // do not forms_.earlyVerify @, password as it is triggered
    // on "show password" clicks, which is boring
    // plus, it will presumably be verified next by click #validClassicSignup
    // 'blur #password': 'earlyVerifyPassword'
    'click #classicSignup': 'validClassicSignup'
  },

  onShow () {
    this.ui.classicUsername.focus()
  },

  serializeData () {
    return {
      passwordLabel: 'password',
      formAction: this.formAction
    }
  },

  // CLASSIC
  validClassicSignup () {
    startLoading.call(this, '#classicSignup')

    return this.verifyClassicUsername()
    .then(this.verifyEmail.bind(this))
    .then(this.verifyPassword.bind(this))
    .then(this.sendClassicSignupRequest.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(stopLoading.bind(this))
  },

  verifyClassicUsername () { return this.verifyUsername('classicUsername') },

  verifyEmail () {
    const email = this.ui.email.val()
    email_.pass(email, '#email')
    return email_.verifyAvailability(email, '#email')
  },

  verifyPassword () { return password_.pass(this.ui.password.val(), '#finalAlertbox') },

  sendClassicSignupRequest () {
    return app.request('signup:classic', {
      username: this.ui.classicUsername.val(),
      password: this.ui.password.val(),
      email: this.ui.email.val()
    })
  },

  // COMMON
  verifyUsername (name) {
    const username = this.ui[name].val()
    return username_.verifyUsername(username, `#${name}`)
  },

  earlyVerifyClassicUsername (e) {
    return forms_.earlyVerify(this, e, this.verifyClassicUsername.bind(this))
  },
  earlyVerifyEmail (e) {
    return forms_.earlyVerify(this, e, this.verifyEmail.bind(this))
  },
  earlyVerifyPassword (e) {
    return forms_.earlyVerify(this, e, this.verifyPassword.bind(this))
  }
})
