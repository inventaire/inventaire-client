module.exports =
  get: (url, options)->
    CORS = options?.CORS

    if _.localUrl(url) or CORS then promise = $.getJSON url
    else promise = $.getJSON "/proxy/#{url}"

    # default fail handler
    # but others canned be chained
    # problem: it might result in several error messages
    promise
    .fail (err)-> _.logXhrErr err, "GET #{url}"

    return promise

  post: (url, body)->
    $.postJSON(url, body)
    .fail (err)-> _.logXhrErr err, "POST #{url}"

  put: (url, body)->
    $.postJSON(url, body)
    .fail (err)-> _.logXhrErr err, "PUT #{url}"

  delete: (url)->
    $.delete(url)
    .fail (err)-> _.logXhrErr err, "DELETE #{url}"