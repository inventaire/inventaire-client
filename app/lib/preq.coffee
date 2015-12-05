Promise::fail = Promise::caught
Promise::always = Promise::finally

Promise.onPossiblyUnhandledRejection (err)->
  label = "[PossiblyUnhandledError] #{err.name}: #{err.message} (#{typeof err.message})"
  stack = err?.stack?.split('\n')
  report = {label: label, error: err, stack: stack}
  if err.message is "[object Object]"
    report.clue = clue = "this is probably an error from a jQuery promise wrapped into a Bluebird one"
  window.reportErr report
  console.error label, stack, clue

module.exports = preq =
  # keep the options object interface to keep the same signature
  # as the server side promises_.get, to ease shared libs
  get: (url, options)->
    if proxiedUrl url then url = app.API.proxy url
    return wrap $.get(url), url

  post: (url, body)-> wrap $.post(url, body), url
  put: (url, body)-> wrap $.put(url, body), url
  delete: (url)-> wrap $.delete(url), url
  getScript: (url)-> wrap $.getScript(url), url

  start: -> Promise.resolve()
  resolve: (res)-> Promise.resolve(res)
  reject: (err)-> Promise.reject(err)

  catch401: (err)-> if err.status is 401 then return
  catch404: (err)-> if err.status is 404 then return

  Sleep: (ms)->
    fn = (res)->
      return new Promise (resolve, reject)->
        cb = -> resolve res
        setTimeout cb, ms

proxiedUrl = (url)-> /wikidata\.org/.test url

preq.wrap = wrap = (jqPromise, url)->
  return new Promise (resolve, reject)->
    jqPromise
    .then resolve
    .fail (err)-> reject rewriteError(err, url)

rewriteError = (err, url)->
  { status, statusText, responseText, responseJSON } = err

  error = new Error "#{status}: #{statusText} - #{responseText} - #{url}"
  return _.extend error,
    status: status
    statusText: statusText
    responseText: responseText
    responseJSON: responseJSON
