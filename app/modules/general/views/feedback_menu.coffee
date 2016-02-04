behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ contact } = require 'lib/urls'

module.exports = Marionette.ItemView.extend
  template: require './templates/feedback_menu'
  className: 'feedback-menu'
  onShow: -> app.execute 'modal:open'
  behaviors:
    Loading: {}
    SuccessCheck: {}
    ElasticTextarea: {}
    General: {}
    PreventDefault: {}

  initialize: -> _.extend @, behaviorsPlugin

  serializeData: ->
    loggedIn: app.user.loggedIn
    user: app.user.toJSON()
    contact: contact
    subject: @options.subject

  ui:
    unknownUser: '.unknownUser'
    subject: '#subject'
    message: '#message'
    sendFeedback: '#sendFeedback'

  events:
    'click a#sendFeedback': 'sendFeedback'

  sendFeedback: ->
    @startLoading('#sendFeedback')
    @postFeedback()
    .then @Check('feedback res', -> app.execute('modal:close'))
    .catch @Fail('feedback err')

  postFeedback: ->
    _.preq.post app.API.feedback,
      subject: _.log @ui.subject.val(), 'subject'
      message: _.log @ui.message.val(), 'message'
      unknownUser: _.log @ui.unknownUser.val(), 'unknownUser'
