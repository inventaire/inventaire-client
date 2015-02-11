Promise::fail = Promise::caught
Promise::always = Promise::finally
Promise.longStackTraces()  if _.env is 'dev'

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
    if _.localUrl(url) or CORS then Promise.resolve $.get(url)
    else Promise.resolve $.get app.API.proxy(url)
  post: (url, body)-> Promise.resolve($.post(url, body))
  put: (url, body)-> Promise.resolve($.put(url, body))
  delete: (url)-> Promise.resolve($.delete(url))

  resolve: (res)-> Promise.resolve(res)
  reject: (err)-> Promise.reject(err)

  catch401: (err)-> if err.status is 401 then return
  catch404: (err)-> if err.status is 404 then return