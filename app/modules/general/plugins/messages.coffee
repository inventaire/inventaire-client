forms_ = require 'modules/general/lib/forms'

# @ui.message MUST be defined
# @lazyRender MUST be defined
# poster MUST expect its arguments to be: id, message, collection
# the id being the id of the object the message will be attached to
module.exports =
  postMessage: (posterReqRes, collection, maxLength)->
    message = @ui.message.val()
    unless @validMessageLength(message, maxLength) then return

    { id } = @model

    app.request posterReqRes, id, message, collection
    .catch @postMessageFail.bind(@, message)

    # empty textarea
    @lazyRender()

  validMessageLength: (message, maxLength = 5000)->
    if message.length is 0 then return false
    if message.length > maxLength
      err = new Error "can't be longer than #{maxLength} characters"
      @postMessageFail message, err
      return false
    return true

  postMessageFail: (message, err)->
    @recoverMessage message
    err.selector = '.alertBox'
    forms_.alert(@, err)

  recoverMessage: (message)-> @ui.message.val message
