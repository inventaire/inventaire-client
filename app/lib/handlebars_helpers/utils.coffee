# inspired by some things there http://assemble.io/helpers/

module.exports =
  join: (array, separator) ->
    unless array? then return ''

    separator = ', '  unless _.isString(separator)
    array.join separator

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def

  joinAuthors: (array)->
    unless array? then return ''
    @join array.map(linkifyAuthors)

linkifyAuthors = (text)->
  "<a href='/search?q=#{text}' class='link searchAuthor'>#{text}</a>"
