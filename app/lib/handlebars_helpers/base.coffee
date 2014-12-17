behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
check = behavior 'success_check'
tip = behavior 'tip'
SafeString = Handlebars.SafeString

base =
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
    partial = new SafeString template(context)
    switch option
      when 'check' then partial = new SafeString check(partial)
    return partial

  firstElement: (obj) ->
    if _.isArray obj then return obj[0]
    else if _.isString obj then return obj
    else return

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

  tip: (text, position)->
    context =
      text: _.i18n text
      position: position or 'rigth'
    new SafeString tip(context)

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

wikidata_claims = require './wikidata_claims'
images = require './images'
input = require './input'
API = _.extend base, wikidata_claims, images, input

module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    for name, fn of API
      register name, fn.bind(API)