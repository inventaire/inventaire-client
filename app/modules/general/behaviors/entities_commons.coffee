module.exports = Marionette.Behavior.extend
  events:
    'click .refreshEntityData': 'refreshEntityData'

  refreshEntityData: -> app.execute 'show:entity:refresh', @view.model
