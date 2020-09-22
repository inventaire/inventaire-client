module.exports =
  pluralize: (type)->
    if type.slice(-1)[0] isnt 's' then type += 's'
    return type
