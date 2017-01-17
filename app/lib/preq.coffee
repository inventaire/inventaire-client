{ reportError } = requireProxy 'lib/reports'
formatStack = require './format_stack'

Promise::fail = Promise::caught
Promise::always = Promise::finally

Promise.onPossiblyUnhandledRejection (err)->
  { lineNumber, columnNumber } = err
  pointer = if lineNumber? then "#{lineNumber}:#{columnNumber}" else ''
  err.message = "[PossiblyUnhandledError] #{err.name}: #{err.message} #{pointer}"
  reportError err

  clue = null
  if err.message is "[object Object]"
    clue = "this is probably an error from a jQuery promise wrapped into a Bluebird one"
  console.error err.message, formatStack(err?.stack), clue or ''

preq = sharedLib('promises')(Promise)

Ajax = (verb, hasBody, allowProxiedUrl=false)->
  return ajax = (url, body)->
    if allowProxiedUrl
      if proxiedUrl(url) then url = app.API.proxy url

    options =
      type: verb
      url: url

    if hasBody
      options.data = JSON.stringify body
      options.headers =
        'content-type': 'application/json'

    return wrap $.ajax(options), options

requestAssets = require './request_assets'

module.exports = _.extend preq, requestAssets,
  get: Ajax 'GET', false, true
  post: Ajax 'POST', true
  put: Ajax 'PUT', true
  delete: Ajax 'DELETE', false

  catch401: (err)-> if err.status isnt 401 then throw err
  catch404: (err)-> if err.status isnt 404 then throw err

proxiedUrl = (url)-> /wikidata\.org/.test url

preq.wrap = wrap = (jqPromise, context)->
  return new Promise (resolve, reject)->
    jqPromise
    .then resolve
    .fail (err)-> reject rewriteError(err, context)

rewriteError = (err, context)->
  { status, statusText, responseText, responseJSON } = err
  { url, type:verb } = context
  if err.status >= 400
    message = "#{status}: #{statusText} - #{responseText} - #{url}"
  else
    # cf http://stackoverflow.com/a/6186905
    # Known case: request blocked by CORS headers
    message = """
      parsing error: #{verb} #{url}
      got status #{status} but invalid JSON: #{responseText} / #{responseJSON}
      """

  error = new Error message
  return _.extend error, { status, statusText, responseText, responseJSON, context }
