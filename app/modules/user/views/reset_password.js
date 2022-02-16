import { tryAsync } from '#lib/promises'
import log_ from '#lib/loggers'
import password_ from '#modules/user/lib/password_tests'
import forms_ from '#modules/general/lib/forms'
import behaviorsPlugin from '#modules/general/plugins/behaviors'
import prepareRedirect from '../lib/prepare_redirect'
import resetPasswordTemplate from './templates/reset_password.hbs'
import '../scss/auth_menu.scss'
import AlertBox from '#behaviors/alert_box'
import Loading from '#behaviors/loading'
import TogglePassword from '#behaviors/toggle_password'
import SuccessCheck from '#behaviors/success_check'

export default Marionette.View.extend({
  className: 'authMenu login',
  template: resetPasswordTemplate,
  behaviors: {
    AlertBox,
    SuccessCheck,
    Loading,
    TogglePassword,
  },

  ui: {
    password: '#password'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    this.formAction = prepareRedirect.call(this, 'home')
  },

  events: {
    'click #updatePassword': 'updatePassword',
    'click #forgotPassword' () { app.execute('show:forgot:password') }
  },

  serializeData () {
    return {
      passwordLabel: 'new password',
      passwordInputName: 'new-password',
      username: app.user.get('username'),
      formAction: this.formAction
    }
  },

  updatePassword () {
    const password = this.ui.password.val()

    return tryAsync(() => password_.pass(password, '#finalAlertbox'))
    .then(this.startLoading.bind(this, '#updatePassword'))
    .then(this.ifViewIsIntact('updateUserPassword', password))
    .then(this.ifViewIsIntact('passwordSuccessCheck'))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(this.stopLoading.bind(this))
  },

  updateUserPassword (password) {
    // Setting currentPassword to null makes it be an empty string on server
    // thus the preference for undefined
    return app.request('password:update', undefined, password, '#password')
    .catch(formatErr)
  },

  passwordSuccessCheck () {
    this.ui.password.val('')
    this.ui.password.trigger('check')
  }
})

const formatErr = function (err) {
  log_.error(err, 'formatErr')
  err.selector = '#finalAlertbox'
  throw err
}
