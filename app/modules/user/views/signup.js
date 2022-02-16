import username_ from '#modules/user/lib/username_tests'
import email_ from '#modules/user/lib/email_tests'
import password_ from '#modules/user/lib/password_tests'
import forms_ from '#modules/general/lib/forms'
import prepareRedirect from '../lib/prepare_redirect'
import { startLoading, stopLoading } from '#modules/general/plugins/behaviors'
import signupTemplate from './templates/signup.hbs'
import '../scss/auth_menu.scss'
import { clickCommand } from '#lib/utils'
import AlertBox from '#behaviors/alert_box'
import Loading from '#behaviors/loading'
import PreventDefault from '#behaviors/prevent_default'
import TogglePassword from '#behaviors/toggle_password'

export default Marionette.View.extend({
  className: 'authMenu signup',
  template: signupTemplate,
  behaviors: {
    AlertBox,
    TogglePassword,
    Loading,
    PreventDefault,
  },

  ui: {
    username: '#username',
    email: '#email',
    suggestionGroup: '#suggestionGroup',
    suggestion: '#suggestion',
    password: '#password'
  },

  initialize () {
    this.formAction = prepareRedirect.call(this)
  },

  events: {
    'blur #username': 'earlyVerifyUsername',
    'blur #email': 'earlyVerifyEmail',
    // do not forms_.earlyVerify @, password as it is triggered
    // on "show password" clicks, which is boring
    // plus, it will presumably be verified next by click #validSignup
    // 'blur #password': 'earlyVerifyPassword'
    'click #signup': 'validSignup',
    'click #login': clickCommand('show:login'),
  },

  onRender () {
    this.ui.username.focus()
  },

  serializeData () {
    return {
      passwordLabel: 'password',
      passwordInputName: 'new-password',
      formAction: this.formAction
    }
  },

  validSignup () {
    startLoading.call(this, '#signup')

    return this.verifyUsername()
    .then(this.verifyEmail.bind(this))
    .then(this.verifyPassword.bind(this))
    .then(this.sendSignupRequest.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(stopLoading.bind(this))
  },

  verifyEmail () {
    const email = this.ui.email.val()
    email_.pass(email, '#email')
    return email_.verifyAvailability(email, '#email')
  },

  verifyPassword () { return password_.pass(this.ui.password.val(), '#finalAlertbox') },

  sendSignupRequest () {
    return app.request('signup', {
      username: this.ui.username.val(),
      password: this.ui.password.val(),
      email: this.ui.email.val()
    })
  },

  async verifyUsername () {
    const username = this.ui.username.val()
    await username_.verifyUsername(username, '#username')
  },

  earlyVerifyUsername (e) {
    return forms_.earlyVerify(this, e, this.verifyUsername.bind(this))
  },
  earlyVerifyEmail (e) {
    return forms_.earlyVerify(this, e, this.verifyEmail.bind(this))
  },
  earlyVerifyPassword (e) {
    return forms_.earlyVerify(this, e, this.verifyPassword.bind(this))
  }
})
