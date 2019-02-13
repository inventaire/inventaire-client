{ reportError } = requireProxy 'lib/reports'

Ajax = (verb, hasBody)->
  return ajax = (url, body)->

    options =
      type: verb
      url: url

    if hasBody
      options.data = JSON.stringify body
      # Do not set content type on cross origin requests as it triggers preflight checks
      # cf https://stackoverflow.com/a/12320736/3324977
      if url[0] is '/' then options.headers = { 'content-type': 'application/json' }

    return wrap $.ajax(options), options
    .then parseJson

preq =
  get: Ajax 'GET', false, true
  post: Ajax 'POST', true
  put: Ajax 'PUT', true
  delete: Ajax 'DELETE', false

requestAssets = require './request_assets'

module.exports = _.extend preq, requestAssets,

preq.wrap = wrap = (jqPromise, context)->
  return new Promise (resolve, reject)->
    jqPromise
    .then resolve
    .fail (err)-> reject rewriteJqueryError(err, context)

parseJson = (res)->
  if _.isString(res) and res[0] is '{' then JSON.parse res
  else res

rewriteJqueryError = (err, context)->
  { status:statusCode, statusText, responseText, responseJSON } = err
  { url, type:verb } = context
  if statusCode >= 400
    messageWithContext = "#{statusCode}: #{statusText} - #{responseText} - #{url}"
    # We need a clean message in case this is to be displayed as an alert
    message = responseJSON?.status_verbose or messageWithContext
  else if statusCode is 0
    app.execute 'flash:message:show:network:error'
    message = 'network error'
  else
    # cf http://stackoverflow.com/a/6186905
    # Known case: request blocked by CORS headers
    message = """
      parsing error: #{verb} #{url}
      got statusCode #{statusCode} but invalid JSON: #{responseText} / #{responseJSON}
      """

  error = new Error message
  return _.extend error, { statusCode, statusText, responseText, responseJSON, context }
