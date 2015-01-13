root = require('app-root-path').path
linkify = require root + '/client/app/lib/handlebars_helpers/linkify'

module.exports = (text)->
  convertMarkdownLinks convertMarkdownBold(text)

convertMarkdownLinks = (text)->
  return text
  .split '['
  .map (part)->
    part
    .split ')'
    .map (subpart)->
      subpart.replace /^(.+)\]\((https?:\/\/.+)/, dynamicLink
    .join ''
  .join ''

# used by String::replace to pass text -> $1 and url -> $2 values
dynamicLink = linkify '$1', '$2'

convertMarkdownBold = (text)->
  text.replace /\*\*([^*]+)\*\*/g, '<strong>$1</strong>'