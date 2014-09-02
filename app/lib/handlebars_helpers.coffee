module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    register 'partial', (name, context) ->
      template = require "views/templates/#{name}"
      if template?
        new Handlebars.SafeString template(context)
      else throw new Error 'handlebars: bad path: template not found'

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

    register 'safe', (text) ->
      new Handlebars.SafeString text

    register 'i18n', (key, args)-> new Handlebars.SafeString _.i18n(key, args)

    register 'P', (id)->
      if id[0] is 'P'
        new Handlebars.SafeString "class='qlabel wdP' resource='https://www.wikidata.org/entity/#{id}'"
      else new Handlebars.SafeString "class='qlabel wdP' resource='https://www.wikidata.org/entity/P#{id}'"

    register 'Q', (id)->
      if id[0] is 'Q'
        new Handlebars.SafeString "class='qlabel wdQ' resource='https://www.wikidata.org/entity/#{id}'"
      else new Handlebars.SafeString "class='qlabel wdQ' resource='https://www.wikidata.org/entity/Q#{id}'"
