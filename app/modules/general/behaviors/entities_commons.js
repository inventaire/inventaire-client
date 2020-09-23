module.exports = Marionette.Behavior.extend
  events:
    'click .refreshEntityData': 'refreshEntityData'
    'click .deduplicateSubEntities': 'deduplicateSubEntities'

  refreshEntityData: -> app.execute 'show:entity:refresh', @view.model
  deduplicateSubEntities: -> app.execute 'show:deduplicate:sub:entities', @view.model
