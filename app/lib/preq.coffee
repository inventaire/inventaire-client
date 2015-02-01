Promise::fail = Promise::caught
Promise::always = Promise::finally

module.exports =
  get: (url, options)->
    CORS = options?.CORS

    if _.localUrl(url) or CORS
      promise = Promise.resolve $.get(url)
    else
      promise = Promise.resolve $.get app.API.proxy(url)

    # default catch handler
    # but others can be chained
    # problem: it might result in several error messages
    promise
    .catch (err)-> _.logXhrErr err, "GET #{url}"

    return promise

  post: (url, body)->
    Promise.resolve($.post(url, body))
    .catch (err)-> _.logXhrErr err, "POST #{url}"

  put: (url, body)->
    Promise.resolve($.put(url, body))
    .catch (err)-> _.logXhrErr err, "PUT #{url}"

  delete: (url)->
    Promise.resolve($.delete(url))
    .catch (err)-> _.logXhrErr err, "DELETE #{url}"

  resolve: (res)-> Promise.resolve(res)
  reject: (err)-> Promise.reject(err)
