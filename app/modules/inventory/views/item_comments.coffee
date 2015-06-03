behaviorsPlugin = require 'modules/general/plugins/behaviors'
messagesPlugin = require 'modules/general/plugins/messages'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  className: 'itemComments panel'
  template: require './templates/item_comments'
  childViewContainer: '.comments'
  childView: require './comment'

  initialize: ->
    [@collection, @fetching] = app.request 'comments:init', @model
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin, messagesPlugin

  events:
    'click .postComment': 'postComment'

  childEvents:
    'edit:toggle': 'toggleNewComment'

  behaviors:
    AlertBox: {}
    Loading: {}
    ElasticTextarea: {}

  ui:
    message: 'textarea.message'
    newCommentDiv: '.newComment'

  serializeData: ->
    user: app.user.toJSON()

  onShow: ->
    if @fetching?
      @startLoading()
      @fetching.finally @stopLoading.bind(@)

  postComment: ->
    @postMessage 'comments:post', @model.comments

  toggleNewComment: ->
    @ui.newCommentDiv.toggle()
