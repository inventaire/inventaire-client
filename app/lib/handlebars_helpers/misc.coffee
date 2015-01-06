{SafeString} = Handlebars

module.exports =
  i18n: (key, args..., data)->
    # key, contextObj form
    if _.isObject(args[0]) then context = args[0]
    # key, context pairs form
    else if args.length % 2 is 0 then context = _.objectifyPairs args
    else context = null
    return _.i18n(key, context)

  I18n: (args...)->
    _.capitaliseFirstLetter @i18n.apply(@, args)

  markdownI18n: (args...)->
    @markdown @i18n.apply(@, args)

  markdown: (text)->
    new SafeString convertMarkdownLinks(convertMarkdownBold(text))

  link: (text, url)->
    text = _.i18n text
    new SafeString linkify(text, url)

  limit: (text, limit)->
    return ''  unless text?
    t = text[0..limit]
    if text.length > limit then t += '[...]'
    new SafeString t

  pre: (text)->
    if text
      text = text.replace /\n/g, '<br>'
      new SafeString text
    else return

  ifvalue: (attr, value)->
    if value? then "#{attr}=#{value}"
    else return

  inlineOptions: (options)->
    str = ''
    str += "#{k}:#{v}; "  for k, v of options
    return str

linkify = (text, url)->
  "<a href='#{url}' class='link' target='_blank'>#{text}</a>"

convertMarkdownLinks = (text)->
  return text
  .split '['
  .map (part)->
    part.replace /^(.+)\]\((https?:\/\/.+)\)/, dynamicLink
  .join ''

# used by String::replace to pass text -> $1 and url -> $2 values
dynamicLink = linkify '$1', '$2'

convertMarkdownBold = (text)->
  text.replace /\*\*([^*]+)\*\*/g, '<strong>$1</strong>'
