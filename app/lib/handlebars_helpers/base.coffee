API = _.extend.apply null, [
  {}
  require './misc'
  require './utils'
  require './partials'
  require './wikidata_claims'
  require './images'
  require './input'
]

module.exports =
  initialize: ->
    # Registering partials using the code here
    # https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
    register = (name, fn) ->
      Handlebars.registerHelper name, fn

    for name, fn of API
      register name, fn.bind(API)