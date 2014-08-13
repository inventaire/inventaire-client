module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    register 'partial', (name, context) ->
      template = require "views/templates/#{name}"
      new Handlebars.SafeString template(context)

    register 'firstElement', (obj) ->
      if _.isArray obj
        return obj[0]
      else if typeof obj is 'string'
        return obj
      else
        return

    register 'icon', (name) ->
      name = name || 'cube'
      new Handlebars.SafeString "<i class='fa fa-#{name}'></i>"

    register 'safe', (text) ->
      new Handlebars.SafeString text

    register 'i18n', (key, args)-> new Handlebars.SafeString _.i18n(key, args)

    register 'P', (id)->
      # propHeader = "<h4 class='qlabel wdP' resource='http://www.wikidata.org/entity/P#{id}'></h4>"
      new Handlebars.SafeString "class='qlabel wdP' resource='https://www.wikidata.org/entity/P#{id}'"

    register 'Q', (id)->
      new Handlebars.SafeString "class='qlabel wdQ' resource='https://www.wikidata.org/entity/Q#{id}'"
