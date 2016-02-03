# /inventory behavior

module.exports = Marionette.Behavior.extend
  events:
    'click .unselect': 'unselect'

  unselect: -> app.execute 'show:inventory:general'
