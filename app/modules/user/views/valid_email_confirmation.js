import { Check } from 'modules/general/plugins/behaviors'
import validEmailConfirmationTemplate from './templates/valid_email_confirmation.hbs'
import '../scss/valid_email_confirmation.scss'
import General from 'behaviors/general'
import Loading from 'behaviors/loading'
import SuccessCheck from 'behaviors/success_check'

export default Marionette.View.extend({
  className: 'validEmailConfirmation',
  template: validEmailConfirmationTemplate,
  behaviors: {
    Loading,
    General,
    SuccessCheck,
  },

  events: {
    'click .showHome, .showLoginRedirectSettings' () { app.execute('modal:close') },
    'click .showLoginRedirectSettings': 'showLoginRedirectSettings',
    'click #emailConfirmationRequest': 'emailConfirmationRequest'
  },

  onRender () {
    app.execute('modal:open')
  },

  serializeData () {
    return {
      validEmail: this.options.validEmail,
      loggedIn: app.user.loggedIn
    }
  },

  emailConfirmationRequest () {
    this.$el.trigger('loading')
    app.request('email:confirmation:request')
    .then(Check.call(this, 'emailConfirmationRequest', app.Execute('modal:close')))
    .catch(emailFail.bind(this))
  },

  showLoginRedirectSettings () {
    app.request('show:login:redirect', 'settings/profile')
  }
})

const emailFail = function () {
  this.$el.trigger('somethingWentWrong')
}
