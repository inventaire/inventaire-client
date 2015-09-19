# inspired by some things there http://assemble.io/helpers/

formatAuthor = require './format_author'

module.exports =
  join: (array, separator) ->
    unless array? then return ''

    separator = ', '  unless _.isString(separator)
    array.join separator

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def

  joinAuthors: (array, linkify)->
    unless array? then return ''
    # defaulting to true while taking care of neutralizing
    # handlebars data object
    unless _.isBoolean linkify then linkify = true
    @join array.map(formatAuthor.bind(null, linkify))
