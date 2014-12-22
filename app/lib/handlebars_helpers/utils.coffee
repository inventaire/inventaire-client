# inspired by some things there http://assemble.io/helpers/

module.exports =
  first: (array) ->
    _.typeArray array
    return array[0]

  join: (array, separator) ->
    _.types [array, separator], 'array', 'string'
    return array.join separator

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def
