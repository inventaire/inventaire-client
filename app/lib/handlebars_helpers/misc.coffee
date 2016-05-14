{ SafeString } = Handlebars

module.exports =
  i18n: (key, args..., data)->
    # this function might be called before the tempates data arrived
    # returning '' early prevents to display undefined and make polyglot worry
    unless key? then return ''
    # key, contextObj OR key, smart_count form
    firstArg = args[0]
    if _.isObject(firstArg) or _.isNumber(firstArg) then context = firstArg
    # key, context pairs form
    else if args.length % 2 is 0 then context = _.objectifyPairs args
    else context = null
    return _.i18n(key, context)

  I18n: (args...)-> _.capitaliseFirstLetter @i18n.apply(@, args)

  capitalize: (str)-> _.capitaliseFirstLetter str

  link: (text, url, classes)->
    new SafeString @linkify(text, url, classes)

  i18nLink: (text, url, context)->
    text = _.i18n text, context
    @link text, url

  limit: (text, limit)->
    return ''  unless text?
    t = text[0..limit]
    if text.length > limit then t += '[...]'
    new SafeString t

  ifvalue: (attr, value)->
    if value? then "#{attr}=#{value}"
    else return

  inlineOptions: (options)->
    str = ''
    str += "#{k}:#{v}; "  for k, v of options
    return str

  linkify: require './linkify'

  qrcode: (url, size)-> _.qrcode(url, size)

  debug: ->
    _.log arguments, 'hb debug arguments'
    _.log this, 'hb debug this'
    return JSON.stringify arguments[0]

  timeFromNow: (time)-> moment(time).fromNow()

  # tailored for Google Books dates:
  # just the year: 1951
  # or the day in the form: 1951-04-12
  dateYear: (date)-> date.split('-')[0]
