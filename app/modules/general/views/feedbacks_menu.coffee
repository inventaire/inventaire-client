behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/feedbacks_menu'
  className: 'feedbacksMenu'
  onShow: -> app.execute 'modal:open'
  behaviors:
    Loading: {}
    SuccessCheck: {}

  initialize: -> _.extend @, behaviorsPlugin

  serializeData: ->
    loggedIn: app.user.loggedIn
    user: app.user.toJSON()

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
    _.preq.post app.API.feedbacks,
      subject: _.log @ui.subject.val(), 'subject'
      message: _.log @ui.message.val(), 'message'
      unknownUser: _.log @ui.unknownUser.val(), 'unknownUser'
