module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn
    register 'partial', (name, context) ->
      template = require "views/templates/#{name}"
      new Handlebars.SafeString template context


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
