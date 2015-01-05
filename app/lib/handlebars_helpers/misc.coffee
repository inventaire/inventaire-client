SafeString = Handlebars.SafeString

module.exports =
  i18n: (key, args..., data)->
    # key, contextObj form
    if _.isObject(args[0]) then context = args[0]
    # key, context pairs form
    else if args.length % 2 is 0 then context = _.objectifyPairs args
    else context = null
    return _.i18n(key, context)

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