import password_ from 'modules/user/lib/password_tests';
import forms_ from 'modules/general/lib/forms';
import behaviorsPlugin from 'modules/general/plugins/behaviors';
import prepareRedirect from '../lib/prepare_redirect';

export default Marionette.ItemView.extend({
  className: 'authMenu login',
  template: require('./templates/reset_password'),
  behaviors: {
    AlertBox: {},
    SuccessCheck: {},
    Loading: {},
    TogglePassword: {}
  },

  ui: {
    password: '#password'
  },

  initialize() {
    _.extend(this, behaviorsPlugin);
    return this.formAction = prepareRedirect.call(this, 'home');
  },

  events: {
    'click #updatePassword': 'updatePassword',
    'click #forgotPassword'() { return app.execute('show:forgot:password'); }
  },

  serializeData() {
    return {
      passwordLabel: 'new password',
      username: app.user.get('username'),
      formAction: this.formAction
    };
  },

  updatePassword() {
    const password = this.ui.password.val();

    return Promise.try(() => password_.pass(password, '#finalAlertbox'))
    .then(this.startLoading.bind(this, '#updatePassword'))
    .then(this.ifViewIsIntact('updateUserPassword', password))
    .then(this.ifViewIsIntact('passwordSuccessCheck'))
    .catch(forms_.catchAlert.bind(null, this))
    .finally(this.stopLoading.bind(this));
  },

  updateUserPassword(password){
    // Setting currentPassword to null makes it be an empty string on server
    // thus the preference for undefined
    return app.request('password:update', undefined, password, '#password')
    .catch(formatErr);
  },

  passwordSuccessCheck() {
    this.ui.password.val('');
    return this.ui.password.trigger('check');
  }
});

var formatErr = function(err){
  _.error(err, 'formatErr');
  err.selector = '#finalAlertbox';
  throw err;
};
