module.exports = ->
  API = _.extend.apply null, [
    {}
    require './blocks'
    require './misc'
    require './utils'
    require './partials'
    require './claims'
    require './user_content'
    require './icons'
    require './images'
    require './input'
  ]
  # Registering partials using the code here
  # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
  register = (name, fn)->
    Handlebars.registerHelper name, fn

  for name, fn of API
    register name, fn.bind(API)
