behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
check = behavior 'success_check'
tip = behavior 'tip'
input = behavior 'input'
wdQ = behavior 'wikidata_Q'
wdP = behavior 'wikidata_P'
img = behavior 'img'
i = behavior 'i'

API =
  partial: (name, context, option) ->
    parts = name.split ':'
    switch parts.length
      when 3 then [module, subfolder, file] = parts
      when 2 then [module, file] = parts
      # defaulting to general:partialName
      when 1 then [module, file] = ['general', name]

    if subfolder? then path = "modules/#{module}/views/#{subfolder}/templates/#{file}"
    else path = "modules/#{module}/views/templates/#{file}"

    template = require path
    partial = new Handlebars.SafeString template(context)
    switch option
      when 'check' then partial = new Handlebars.SafeString check(partial)
    return partial

  firstElement: (obj) ->
    if _.isArray obj then return obj[0]
    else if _.isString obj then return obj
    else return

  icon: (name, classes) ->
    if _.isString(name)
      if icons[name]?
        src = icons[name]
        return new Handlebars.SafeString "<img class='icon svg' src='#{src}'>"
      else
        # overriding the second argument that could be {hash:,data:}
        unless _.isString classes then classes = ''
        return new Handlebars.SafeString "<i class='fa fa-#{name} #{classes}'></i>&nbsp;&nbsp;"

  i18n: (key, args, context)-> new Handlebars.SafeString _.i18n(key, args, context)

  P: (id)->
    if /^P[0-9]+$/.test id
      new Handlebars.SafeString wdP({id: id})
    else new Handlebars.SafeString wdP({id: "P#{id}"})

  Q: (claims, P, link)->
    if claims?[P]?
      # when link args is omitted, the {data:,hash: }
      # makes it truthy, thus the stronger test:
      link = link is true
      values = claims[P].map (Q)-> wdQ({id: Q, link: link})
      return new Handlebars.SafeString values.join ', '
    else
      _.log arguments, 'claim couldnt be displayed by Handlebars'
      return

  claim: (claims, P, link)->
    if claims?[P]?
      label = @P(P)
      value = @Q(claims, P, link)
      return new Handlebars.SafeString "#{label} #{value} <br>"

  timeClaim: (claims, P, format='year')->
    if claims?[P]?
      values = claims[P].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then time = time.getUTCFullYear()
        return time
      values = _.uniq(values)
      return new Handlebars.SafeString values.join(_.i18n(' or '))

  limit: (text, limit)->
    if text?
      t = text[0..limit]
      if text.length > limit
        t += '[...]'
      new Handlebars.SafeString t
    else ''

  tip: (text, position)->
    context =
      text: _.i18n text
      position: position || 'rigth'
    new Handlebars.SafeString tip(context)

  placeholder: (height=250, width=200)->
    _.placeholder(height, width)

  input: (data, options)->
    unless data?
      _.log arguments, 'input arguments @err'
      throw new Error 'no data'

    # default data, overridident by arguments
    field =
      type: 'text'
    button =
      classes: 'success postfix'

    name = data.nameBase
    if name?
      field.id = name + 'Field'
      field.placeholder = _.i18n(name)
      button.id = name + 'Button'
      button.text = name

    if data.button?.icon?
      data.button.text = "<i class='fa fa-#{data.button.icon}'></i>"

    # data overriding happens here
    data =
      id: "#{name}Group"
      field: _.extend field, data.field
      button: _.extend button, data.button

    if data.special
      data.special = 'autocorrect="off" autocapitalize="off" autocomplete="off"'

    i = new Handlebars.SafeString input(data)

    if options is 'check' then new Handlebars.SafeString check(i)
    else i

  pre: (text)->
    if text
      text = text.replace /\n/g, '<br>'
      new Handlebars.SafeString text
    else return

  ifvalue: (attr, value)->
    if value? then "#{attr}=#{value}"
    else return

icons =
  wikipedia: 'https://upload.wikimedia.org/wikipedia/en/8/80/Wikipedia-logo-v2.svg'
  wikidata: 'https://upload.wikimedia.org/wikipedia/commons/f/ff/Wikidata-logo.svg'
  wikidataWhite: 'http://img.inventaire.io/Wikidata-logo-white.svg'
  wikisource: 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Wikisource-logo.svg'

module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    for name, fn of API
      register name, fn.bind(API)