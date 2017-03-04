Comments = require './collections/comments'
poster_ = require 'lib/poster'

module.exports = ->
  app.reqres.setHandlers
    'comments:init': initComments
    'comments:post': postComment
    'comments:update': updateComment
    'comments:delete': deleteComment

initComments = (model)->
  fetching = null
  # init collection unless it was already done
  unless model.comments?
    model.comments = comments = new Comments [], {item: model}
    fetching = fetchComments model.id, comments

  return [model.comments, fetching]

fetchComments = (itemId, commentsCollection)->
  _.preq.get _.buildPath(app.API.comments.public, { item: itemId })
  .then commentsCollection.add.bind(commentsCollection)

postComment = (itemId, message, commentsCollection)->
  comment =
    item: itemId
    message: message

  commentModel = addComment comment, commentsCollection

  _.preq.post app.API.comments.authentified, comment
  .then poster_.UpdateModelIdRev(commentModel)
  .catch poster_.Rewind(commentModel, commentsCollection)
  .catch _.ErrorRethrow('postComment')

addComment = (comment, commentsCollection)->
  # adding elements set by the server firgures out alone
  _.extend comment,
    user: app.user.id
    created: Date.now()

  return commentsCollection.add comment

updateComment = (commentModel, newMessage)->
  currentMessage = commentModel.get 'message'
  if newMessage is currentMessage then return _.preq.resolved

  commentModel.set
    message: newMessage
    edited: Date.now()

  _.preq.put app.API.comments.authentified,
    id: commentModel.id
    message: newMessage

# requires the view to register to the ConfirmationModal behavior
deleteComment = (commentModel, view)->
  view.$el.trigger 'askConfirmation',
    confirmationText: _.i18n 'comment_delete_confirmation'
    warningText: _.i18n 'cant_undo_warning'
    action: commentModel.destroy.bind(commentModel)
    selector: view.uniqueSelector