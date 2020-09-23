import { Check } from 'modules/general/plugins/behaviors';

export default Marionette.ItemView.extend({
  className: 'validEmailConfirmation',
  template: require('./templates/valid_email_confirmation'),
  behaviors: {
    Loading: {},
    General: {},
    SuccessCheck: {}
  },

  events: {
    'click .showHome, .showLoginRedirectSettings'() { return app.execute('modal:close'); },
    'click .showLoginRedirectSettings': 'showLoginRedirectSettings',
    'click #emailConfirmationRequest': 'emailConfirmationRequest'
  },

  onShow() {  return app.execute('modal:open'); },

  serializeData() {
    return {
      validEmail: this.options.validEmail,
      loggedIn: app.user.loggedIn
    };
  },

  emailConfirmationRequest() {
    this.$el.trigger('loading');
    return app.request('email:confirmation:request')
    .then(Check.call(this, 'emailConfirmationRequest', app.Execute('modal:close')))
    .catch(emailFail.bind(this));
  },

  showLoginRedirectSettings() {
    return app.request('show:login:redirect', 'settings/profile');
  }
});

var emailFail = function() { return this.$el.trigger('somethingWentWrong'); };
