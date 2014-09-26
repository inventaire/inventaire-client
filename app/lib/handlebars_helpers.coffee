check = require 'views/behaviors/templates/success_check'
tip = require 'views/behaviors/templates/tip'

module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    register 'partial', (name, context, option) ->
      template = require "views/templates/#{name}"
      str = new Handlebars.SafeString template(context)
      switch option
        when 'check' then str = new Handlebars.SafeString check(str)
      return str

    register 'firstElement', (obj) ->
      if _.isArray obj
        return obj[0]
      else if typeof obj is 'string'
        return obj
      else
        return

    register 'icon', (name, classes) ->
      name = name || 'cube'
      if typeof classes is 'string' and classes.length > 0
        new Handlebars.SafeString "<i class='fa fa-#{name} #{classes}'></i>&nbsp;"
      else new Handlebars.SafeString "<i class='fa fa-#{name}'></i>&nbsp;"

    register 'safe', (text) -> new Handlebars.SafeString text

    register 'i18n', (key, args)-> new Handlebars.SafeString _.i18n(key, args)

    register 'P', (id)->
      if /^P[0-9]+$/.test id
        new Handlebars.SafeString "class='qlabel wdP' resource='https://www.wikidata.org/entity/#{id}'"
      else new Handlebars.SafeString "class='qlabel wdP' resource='https://www.wikidata.org/entity/P#{id}'"

    register 'Q', (id)->
      if /^Q[0-9]+$/.test id
        new Handlebars.SafeString "class='qlabel wdQ' resource='https://www.wikidata.org/entity/#{id}'"
      else new Handlebars.SafeString "class='qlabel wdQ' resource='https://www.wikidata.org/entity/Q#{id}'"

    register 'limit', (text, limit)->
      if text?
        t = text[0..limit]
        if text.length > limit
          t += '[...]'
        new Handlebars.SafeString t
      else ''

    register 'tip', (text, position)->
      context =
        text: _.i18n text
        position: position || 'rigth'
      new Handlebars.SafeString tip(context)

    register 'placeholder', (height=250, width=200)->
      _.placeholder(height, width)