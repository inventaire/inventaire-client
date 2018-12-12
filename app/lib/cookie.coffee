module.exports =
  # sync
  get: (key)->
    value = $.cookie key
    return parseCookieValue value

  # async
  set: (key, value)->
    _.preq.post app.API.cookie, { key, value }
    .catch _.Error("cookie_.set: failed: #{key} - #{value}")

parseCookieValue = (value)->
  switch value
    when 'true' then true
    when 'false' then false
    else value
