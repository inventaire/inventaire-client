events =
  'click .unselect': 'unselect'

handlers =
  unselect: ->
    app.execute 'show:inventory:general'

module.exports = _.BasicPlugin events, handlers
