import { tryAsync } from '#lib/promises'
import { isEmail } from '#lib/boolean_tests'
import username_ from '#user/lib/username_tests'
import password_ from '#user/lib/password_tests'
import forms_ from '#general/lib/forms'
import behaviorsPlugin from '#general/plugins/behaviors'
import prepareRedirect from '../lib/prepare_redirect.js'
import loginTemplate from './templates/login.hbs'
import { clickCommand } from '#lib/utils'
import '../scss/auth_menu.scss'
import AlertBox from '#behaviors/alert_box'
import Loading from '#behaviors/loading'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'
import TogglePassword from '#behaviors/toggle_password'

export default Marionette.View.extend({
  className: 'authMenu login',
  template: loginTemplate,
  events: {
    'blur #username': 'earlyVerifyUsername',
    'click #login': 'loginAttempt',
    'click #createAccount': clickCommand('show:signup'),
    'click #forgotPassword': clickCommand('show:forgot:password'),
  },

  behaviors: {
    Loading,
    SuccessCheck,
    AlertBox,
    TogglePassword,
    PreventDefault,
  },

  ui: {
    username: '#username',
    password: '#password'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    this.formAction = prepareRedirect.call(this)
  },

  onRender () {
    this.ui.username.focus()
  },

  serializeData () {
    return {
      passwordLabel: 'password',
      passwordInputName: 'current-password',
      formAction: this.formAction
    }
  },

  loginAttempt (e) {
    return tryAsync(this.verifyUsername.bind(this))
    .then(this.verifyPassword.bind(this))
    .then(this.login.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
  },

  verifyUsername (username) {
    username = this.ui.username.val()
    if (!isEmail(username)) return username_.pass(username, '#username')
  },

  earlyVerifyUsername (e) {
    return forms_.earlyVerify(this, e, this.verifyUsername.bind(this))
  },

  verifyPassword () {
    return password_.pass(this.ui.password.val(), '#finalAlertbox')
  },

  login () {
    const username = this.ui.username.val()
    const password = this.ui.password.val()
    this.startLoading('#login')
    return app.request('login', username, password)
    .catch(this.loginError.bind(this))
  },

  loginError (err) {
    this.stopLoading()
    if (err.statusCode === 401) {
      return this.alert(this.getErrMessage())
    } else {
      throw err
    }
  },

  getErrMessage () {
    const username = this.ui.username.val()
    if (isEmail(username)) {
      return 'email or password is incorrect'
    } else {
      return 'username or password is incorrect'
    }
  }
})
