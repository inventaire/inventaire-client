module.exports =
  get: (url, CORS)->
    if CORS then $.getJSON url
    else $.getJSON "/proxy/#{url}"