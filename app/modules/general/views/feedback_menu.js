import behaviorsPlugin from 'modules/general/plugins/behaviors';
import { contact } from 'lib/urls';

export default Marionette.ItemView.extend({
  template: require('./templates/feedback_menu'),
  className() {
    const standalone = this.options.standalone ? 'standalone' : '';
    return `feedback-menu ${standalone}`;
  },

  behaviors: {
    Loading: {},
    SuccessCheck: {},
    ElasticTextarea: {},
    General: {},
    PreventDefault: {}
  },

  initialize() {
    _.extend(this, behaviorsPlugin);
    return ({ standalone: this.standalone } = this.options);
  },

  serializeData() {
    return {
      loggedIn: app.user.loggedIn,
      user: app.user.toJSON(),
      contact,
      subject: this.options.subject,
      standalone: this.standalone
    };
  },

  ui: {
    unknownUser: '.unknownUser',
    subject: '#subject',
    message: '#message',
    sendFeedback: '#sendFeedback',
    confirmation: '#confirmation'
  },

  events: {
    'click a#sendFeedback': 'sendFeedback'
  },

  onShow() { if (!this.standalone) { return app.execute('modal:open'); } },

  sendFeedback() {
    this.startLoading('#sendFeedback');

    return this.postFeedback()
    .then(this.confirm.bind(this))
    .catch(this.postFailed.bind(this));
  },

  postFeedback() {
    return app.request('post:feedback', {
      subject: this.ui.subject.val(),
      uris: this.options.uris,
      message: this.ui.message.val(),
      unknownUser: this.ui.unknownUser.val()
    }
    );
  },

  confirm() {
    this.stopLoading('#sendFeedback');
    this.ui.subject.val(null);
    this.ui.message.val(null);
    this.ui.confirmation.slideDown();

    if (this.standalone) {
      // simply hide the confirmation so that the user can still send a new feedback
      // and get a new confirmation for it
      return this.setTimeout(this.hideConfirmation.bind(this), 5000);
    } else {
      return this.setTimeout(app.Execute('modal:close'), 2000);
    }
  },

  postFailed() {
    this.stopLoading('#sendFeedback');
    return this.fail('feedback err');
  },

  hideConfirmation() { if (!this.isDestroyed) { return this.ui.confirmation.slideUp(); } }
});
