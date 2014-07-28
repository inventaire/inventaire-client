module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn
    register 'partial', (name, context) ->
      template = require "views/templates/#{name}"
      new Handlebars.SafeString template context


    register 'firstElement', (array) ->
      return array[0]

    register 'icon', (name) ->
      if name?
        return name
      else return'cube'