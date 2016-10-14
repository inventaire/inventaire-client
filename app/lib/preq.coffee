Promise::fail = Promise::caught
Promise::always = Promise::finally

Promise.onPossiblyUnhandledRejection (err)->
  { lineNumber, columnNumber } = err
  pointer = if lineNumber? then "#{lineNumber}:#{columnNumber}" else ''
  label = "[PossiblyUnhandledError] #{err.name}: #{err.message} #{pointer}"
  stack = err?.stack?.split('\n')
  report = {label: label, error: err, stack: stack}
  if err.message is "[object Object]"
    report.clue = clue = "this is probably an error from a jQuery promise wrapped into a Bluebird one"
  window.reportErr report
  console.error label, stack, clue

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

module.exports = _.extend preq,
  get: Ajax 'GET', false, true
  post: Ajax 'POST', true
  put: Ajax 'PUT', true
  delete: Ajax 'DELETE', false

  getScript: (url)-> wrap $.getScript(url), { type: 'GET', url }

  catch401: (err)-> if err.status is 401 then return
  catch404: (err)-> if err.status is 404 then return

  Sleep: (ms)->
    fn = (res)->
      return new Promise (resolve, reject)->
        cb = -> resolve res
        setTimeout cb, ms

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
    message = """
      parsing error: #{verb} #{url}
      got status #{status} but invalid JSON: #{responseText}
      """

  error = new Error message
  return _.extend error,
    status: status
    statusText: statusText
    responseText: responseText
    responseJSON: responseJSON
    context: context
