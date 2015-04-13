Comments = require './collections/comments'

module.exports = ->
  app.reqres.setHandlers
    'comments:init': initComments
    'comments:fetch': fetchComments
    'comments:post': postComment


initComments = (model)->
  # init collection unless it was already done
  unless model.comments?
    model.comments = comments = new Comments
    fetchComments model.id, comments

  return model.comments

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
