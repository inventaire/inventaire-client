events =
  'click .unselect': 'unselect'

handlers =
  unselect: ->
    app.execute 'show:inventory:general'

module.exports = ->
  @events or= {}
  _.extend @events, events
  _.extend @, handlers
