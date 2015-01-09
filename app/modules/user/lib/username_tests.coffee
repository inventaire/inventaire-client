module.exports =
  validate: (options)->
    {username, success, view} = options
    for err, test of commonTests
      if test(username)
        @invalidUsername.call view, err
        return false
    return success(username)

  invalidUsername: (err)->
    if _.isString err then errMessage = err
    else
      errMessage = err.responseJSON.status_verbose or "invalid username"
    @$el.trigger 'alert', {message: _.i18n(errMessage)}


commonTests =
  "username can't be empty" : (username)->
    username is ''

  'username should be 20 character maximum' : (username)->
    username.length > 20

  "username can't contain space" : (username)->
    /\s/.test username

  'username can only contain letters, figures or _' : (username)->
    /\W/.test username

