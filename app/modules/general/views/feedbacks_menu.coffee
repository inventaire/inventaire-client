loadingPlugin = require 'modules/general/plugins/loading'

module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/feedbacks_menu'
  className: 'feedbacksMenu'
  onShow: -> app.execute 'modal:open'
  behaviors:
    Loading: {}
    SuccessCheck: {}

  initialize: -> _.extend @, loadingPlugin

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
    .then @success.bind(@)
    .catch @error.bind(@)

  postFeedback: ->
    _.preq.post app.API.feedbacks,
      subject: _.log @ui.subject.val(), 'subject'
      message: _.log @ui.message.val(), 'message'
      unknownUser: _.log @ui.unknownUser.val(), 'unknownUser'

  success: (res)->
    @$el.trigger 'check', -> app.execute('modal:close')
    _.log res, 'res'

  error: (err)->
    @$el.trigger 'fail'
    _.error err, 'err'
