forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  className: 'itemComments'
  template: require './templates/item_comments'
  childViewContainer: '.comments'
  childView: require './comment'

  initialize: ->
    @collection = app.request 'comments:init', @model

  events:
    'click .postComment': 'postComment'

  behaviors:
    AlertBox: {}

  ui:
    message: 'textarea.message'

  serializeData: ->
    user: app.user.toJSON()

  postComment: ->
    id = @model.id
    message = @ui.message.val()
    collection = @model.comments

    app.request 'comments:post', id, message, collection
    .catch @postCommentFail.bind(@, message)

    @emptyTextarea()

  postCommentFail: (message, err)->
    @recoverMessage message
    err.selector = 'textarea.message'
    forms_.alert(@, err)

  emptyTextarea: -> @ui.message.val('')
  recoverMessage: (message)-> @ui.message.val message
