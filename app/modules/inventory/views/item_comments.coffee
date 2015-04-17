behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  className: 'itemComments'
  template: require './templates/item_comments'
  childViewContainer: '.comments'
  childView: require './comment'

  initialize: ->
    [@collection, @fetching] = app.request 'comments:init', @model
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin

  events:
    'click .postComment': 'postComment'

  behaviors:
    AlertBox: {}
    Loading: {}
    ElasticTextarea: {}

  ui:
    message: 'textarea.message'

  serializeData: ->
    user: app.user.toJSON()

  onShow: ->
    @startLoading()
    @fetching.finally @stopLoading.bind(@)

  onRender: ->
    @ui.message.elastic()

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
