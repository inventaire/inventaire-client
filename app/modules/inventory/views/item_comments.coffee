behaviorsPlugin = require 'modules/general/plugins/behaviors'
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
    _.extend @, behaviorsPlugin

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

  onRender: ->
    @ui.message.elastic()

  postComment: ->
    message = @ui.message.val()
    return  unless @validCommentLength(message)

    itemId = @model.id
    collection = @model.comments

    app.request 'comments:post', itemId, message, collection
    .catch @postCommentFail.bind(@, message)

    @emptyTextarea()

  validCommentLength: (message)->
    if message.length is 0 then return false
    if message.length > 5000
      err = new Error("comment can't be longer than 5000 characters")
      @postCommentFail message, err
      return false
    return true

  postCommentFail: (message, err)->
    @recoverMessage message
    err.selector = '.alertBox'
    forms_.alert(@, err)

  emptyTextarea: -> @ui.message.val('')
  recoverMessage: (message)-> @ui.message.val message

  toggleNewComment: ->
    @ui.newCommentDiv.toggle()
