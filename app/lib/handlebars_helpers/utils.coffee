# inspired by some things there http://assemble.io/helpers/

module.exports =
  first: (array) ->
    _.typeArray array
    return array[0]

  join: (array, separator) ->
    if array?
      separator = ', '  unless _.isString(separator)
      array.join separator
    else ''

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def
