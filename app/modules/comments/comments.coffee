Comments = require './collections/comments'

module.exports = ->
  app.reqres.setHandlers
    'comments:init': initComments
    'comments:post': postComment
    'comments:update': updateComment
    'comments:delete': deleteComment

initComments = (model)->
  # init collection unless it was already done
  unless model.comments?
    model.comments = comments = new Comments [], {item: model}
    fetching = fetchComments model.id, comments

  return [model.comments, fetching]

fetchComments = (itemId, commentsCollection)->
  _.preq.get _.buildPath(app.API.comments, { item: itemId })
  .then _.Log('comments?')
  .then commentsCollection.add.bind(commentsCollection)


postComment = (itemId, message, commentsCollection)->
  comment =
    item: itemId
    message: message

  commentModel = addComment comment, commentsCollection

  _.preq.post app.API.comments, comment
  .catch postCommentFail.bind(null, commentModel, commentsCollection)


addComment = (comment, commentsCollection)->
  # adding elements set by the server firgures out alone
  _.extend comment,
    user: app.user.id
    time: _.now()

  return commentsCollection.add comment

postCommentFail = (commentModel, commentsCollection, err)->
  commentsCollection.remove(commentModel)
  throw err


updateComment = (commentModel, newMessage)->
  currentMessage = commentModel.get 'message'
  if newMessage is currentMessage then return _.preq.resolve()

  commentModel.set 'message', newMessage

  _.preq.put app.API.comments,
    id: commentModel.id
    message: newMessage

# requires the view to register to the ConfirmationModal behavior
deleteComment = (commentModel, view)->
  view.$el.trigger 'askConfirmation',
    confirmationText: _.i18n 'comment_delete_confirmation'
    warningText: _.i18n 'cant_undo_warning'
    action: -> _.preq.resolve commentModel.destroy()
    selector: view.uniqueSelector