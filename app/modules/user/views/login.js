import username_ from 'modules/user/lib/username_tests'
import password_ from 'modules/user/lib/password_tests'
import forms_ from 'modules/general/lib/forms'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import prepareRedirect from '../lib/prepare_redirect'

export default Marionette.ItemView.extend({
  className: 'authMenu login',
  template: require('./templates/login'),
  events: {
    'blur #username': 'earlyVerifyUsername',
    'click #classicLogin': 'classicLoginAttempt',
    'click #createAccount' () { app.execute('show:signup') },
    'click #forgotPassword' () { app.execute('show:forgot:password') }
  },

  behaviors: {
    Loading: {},
    SuccessCheck: {},
    AlertBox: {},
    TogglePassword: {}
  },

  ui: {
    username: '#username',
    password: '#password'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    this.formAction = prepareRedirect.call(this)
  },

  onShow () {
    this.ui.username.focus()
  },

  serializeData () {
    return {
      passwordLabel: 'password',
      formAction: this.formAction
    }
  },

  classicLoginAttempt () {
    return Promise.try(this.verifyUsername.bind(this))
    .then(this.verifyPassword.bind(this))
    .then(this.classicLogin.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
  },

  verifyUsername (username) {
    username = this.ui.username.val()
    if (_.isEmail(username)) {

    } else { return username_.pass(username, '#username') }
  },

  earlyVerifyUsername (e) {
    return forms_.earlyVerify(this, e, this.verifyUsername.bind(this))
  },

  verifyPassword () {
    return password_.pass(this.ui.password.val(), '#finalAlertbox')
  },

  classicLogin () {
    const username = this.ui.username.val()
    const password = this.ui.password.val()
    this.startLoading('#classicLogin')
    return app.request('login:classic', username, password)
    .catch(this.loginError.bind(this))
  },

  loginError (err) {
    this.stopLoading()
    if (err.statusCode === 401) {
      return this.alert(this.getErrMessage())
    } else { throw err }
  },

  getErrMessage () {
    const username = this.ui.username.val()
    if (_.isEmail(username)) {
      return 'email or password is incorrect'
    } else { return 'username or password is incorrect' }
  }
})
