# inspired by some things there http://assemble.io/helpers/
{ SafeString, escapeExpression } = Handlebars

module.exports =
  join: (array, separator)->
    unless array? then return ''

    separator = ', '  unless _.isString(separator)
    array.join separator

  log: (args, data)-> _.log.apply _, args

  default: (text, def)-> text or def

  joinAuthors: (array)->
    array = _.compact array
    unless array?.length > 0 then return ''
    return new SafeString(@join(array.map(linkifyAuthorString)) + '<br>')

linkifyAuthorString = (text)->
  str = escapeExpression text
  q = _.fixedEncodeURIComponent text
  return "<a href='/search?q=#{q}' class='link searchAuthor'>#{str}</a>"
