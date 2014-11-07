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