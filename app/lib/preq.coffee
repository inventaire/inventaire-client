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

module.exports =
  get: (url, options)->
    CORS = options?.CORS
    if _.localUrl(url) or CORS then jqPromise = $.get(url)
    else jqPromise = $.get app.API.proxy(url)

    return wrap(jqPromise)

  post: (url, body)-> wrap($.post(url, body))
  put: (url, body)-> wrap($.put(url, body))
  delete: (url)-> wrap($.delete(url))

  resolve: (res)-> Promise.resolve(res)
  reject: (err)-> Promise.reject(err)

  catch401: (err)-> if err.status is 401 then return
  catch404: (err)-> if err.status is 404 then return


# using defer might be an anti-pattern
# according to http://stackoverflow.com/q/24315180/3324977
# but it allows to rewrite the Error to keep jQuery error's data
wrap = (jqPromise)->
  def = Promise.defer()

  jqPromise
  .then def.resolve.bind(def)
  .fail (err)-> def.reject rewriteError(err)

  return def.promise


rewriteError = (err)->
  {status, statusText, responseText} = err

  error = new Error "#{status}: #{statusText} - #{responseText}"
  return _.extend error,
    status: status
    statusText: statusText
    responseText: responseText