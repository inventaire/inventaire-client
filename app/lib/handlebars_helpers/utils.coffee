# inspired by some things there http://assemble.io/helpers/

linkifyAuthor = require './linkify_author'

module.exports =
  join: (array, separator) ->
    unless array? then return ''

    separator = ', '  unless _.isString(separator)
    array.join separator

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def

  joinAuthors: (array)->
    unless array? then return ''
    @join array.map(linkifyAuthor)
