module.exports = Marionette.Behavior.extend
  events:
    'click .refreshEntityData': 'refreshEntityData'
    'click .deduplicateEntity': 'deduplicateEntity'
    'click .deduplicateSubEntities': 'deduplicateSubEntities'

  refreshEntityData: -> app.execute 'show:entity:refresh', @view.model
  deduplicateEntity: -> app.execute 'show:deduplicate:entity', @view.model
  deduplicateSubEntities: -> app.execute 'show:deduplicate:sub:entities', @view.model
