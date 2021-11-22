import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { contact } from 'lib/urls'
import feedbackMenuTemplate from './templates/feedback_menu.hbs'
import '../scss/feedback.scss'
import ElasticTextarea from 'behaviors/elastic_textarea'
import General from 'behaviors/general'
import Loading from 'behaviors/loading'
import PreventDefault from 'behaviors/prevent_default'
import SuccessCheck from 'behaviors/success_check'

export default Marionette.View.extend({
  template: feedbackMenuTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `feedback-menu ${standalone}`
  },

  behaviors: {
    ElasticTextarea,
    General,
    Loading,
    PreventDefault,
    SuccessCheck,
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

  onRender () { if (!this.standalone) { app.execute('modal:open') } },

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
    this.ui.confirmation.attr('role', 'alert')
    this.ui.confirmation.slideDown()

    // Simply hide the confirmation so that the user can still send a new feedback
    // and get a new confirmation for it
    this.setTimeout(this.hideConfirmation.bind(this), 30000)
  },

  postFailed () {
    this.stopLoading('#sendFeedback')
    this.fail('feedback err')
  },

  hideConfirmation () {
    if (this.isDestroyed) return
    this.ui.confirmation.slideUp()
    this.ui.confirmation.removeAttr('role')
  }
})
