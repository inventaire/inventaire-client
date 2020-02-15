{ SafeString, escapeExpression } = Handlebars
{ parseQuery } = requireProxy 'lib/location'
timeFromNow = requireProxy 'lib/time_from_now'
wdPropPrefix = 'wdt:'

module.exports =
  i18n: (key, context)->
    # This function might be called before the tempates data arrived
    # returning '' early prevents to display undefined and make polyglot worry
    unless key? then return ''
    # easying the transition to a property system with prefixes
    # TODO: format i18n wikidata source files to include prefixes
    # and get rid of this hack
    if key[0..3] is wdPropPrefix then key = key.replace wdPropPrefix, ''
    # Allow to pass context through Handlebars hash object
    # ex: {{{i18n 'email_invitation_sent' email=this}}}
    # Use this mode for unsafe context values to get it escaped
    if _.isObject context?.hash then context = escapeValues context.hash
    return _.i18n key, context

  I18n: (args...)-> _.capitalise @i18n.apply(@, args)

  I18nStartCase: (args...)->
    @i18n.apply @, args
    .split ' '
    .map _.capitalise
    .join ' '

  linkify: require './linkify'

  i18nLink: (text, url, context)->
    text = _.i18n text, context
    @link text, url

  I18nLink: (text, url, context)->
    text = _.capitalise _.i18n(text, context)
    @link text, url

  # See also: iconLinkText
  link: (text, url, classes, title)->
    # Polymorphism: accept arguments as hash key/value pairs
    # ex: {{link i18n='see_on_website' i18nArgs='website=wikidata.org' url=wikidata.url classes='link'}}
    if _.isObject text.hash
      { text, i18n, i18nArgs, url, classes, title, titleAttrKey, titleAttrValue, simpleOpenedAnchor } = text.hash

      if titleAttrKey?
        titleArgs = {}
        titleArgs[titleAttrKey] = titleAttrValue
        title = _.i18n title, titleArgs

      unless text?
        # A flag to build a complex <a> tag but with more tags between the anchor tags
        if simpleOpenedAnchor
          text = ''
        else
          # Expect i18nArgs to be a string formatted as a querystring
          i18nArgs = parseQuery i18nArgs
          text = _.i18n i18n, i18nArgs

    link = @linkify text, url, classes, title

    if simpleOpenedAnchor
      # Return only the first tag to let the possibility to add a complex innerHTML
      return new SafeString link.replace('</a>', '')
    else
      return new SafeString link

  capitalize: (str)-> _.capitalise str

  limit: (text, limit)->
    unless text? then return ''
    t = text[0..limit]
    if text.length > limit then t += '[...]'
    new SafeString t

  debug: ->
    _.log arguments, 'hb debug arguments'
    return JSON.stringify arguments[0]

  localTimeString: (time)-> if time? then new Date(time).toLocaleString()

  timeFromNow: (time)->
    unless time? then return
    { key, amount } = timeFromNow time
    return _.i18n key, { smart_count: amount }

  stringify: (obj)->
    if _.isString obj then obj
    else JSON.stringify obj, null, 2

escapeValues = (obj)->
  for key, value of obj
    obj[key] = escapeExpression value
  return obj
