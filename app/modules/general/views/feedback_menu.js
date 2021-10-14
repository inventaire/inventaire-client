import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { contact } from 'lib/urls'
import feedbackMenuTemplate from './templates/feedback_menu.hbs'
import '../scss/feedback.scss'
export default Marionette.ItemView.extend({
  template: feedbackMenuTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `feedback-menu ${standalone}`
  },

  behaviors: {
    Loading: {},
    SuccessCheck: {},
    ElasticTextarea: {},
    General: {},
    PreventDefault: {}
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    this.standalone = this.options.standalone
  },

  serializeData () {
    return {
      loggedIn: app.user.loggedIn,
      user: app.user.toJSON(),
      contact,
      subject: this.options.subject,
      standalone: this.standalone
    }
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

  onShow () { if (!this.standalone) { app.execute('modal:open') } },

  sendFeedback () {
    if (this.ui.subject.val().trim().length === 0) return
    if (this.ui.message.val().trim().length === 0) return

    this.startLoading('#sendFeedback')

    return this.postFeedback()
    .then(this.confirm.bind(this))
    .catch(this.postFailed.bind(this))
  },

  postFeedback () {
    return app.request('post:feedback', {
      subject: this.ui.subject.val(),
      uris: this.options.uris,
      message: this.ui.message.val(),
      unknownUser: this.ui.unknownUser.val()
    })
  },

  confirm () {
    this.stopLoading('#sendFeedback')
    this.ui.subject.val(null)
    this.ui.message.val(null)
    this.ui.confirmation.slideDown()

    if (this.standalone) {
      // simply hide the confirmation so that the user can still send a new feedback
      // and get a new confirmation for it
      this.setTimeout(this.hideConfirmation.bind(this), 5000)
    } else {
      this.setTimeout(app.Execute('modal:close'), 2000)
    }
  },

  postFailed () {
    this.stopLoading('#sendFeedback')
    this.fail('feedback err')
  },

  hideConfirmation () { if (!this.isDestroyed) { this.ui.confirmation.slideUp() } }
})
