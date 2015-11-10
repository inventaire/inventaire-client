events =
  'click .unselect': 'unselect'

handlers =
  unselect: ->
    if window.history.length > 1 then window.history.back()
    else app.execute 'show:inventory:general'

module.exports = _.BasicPlugin events, handlers
