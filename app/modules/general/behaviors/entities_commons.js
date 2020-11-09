export default Marionette.Behavior.extend({
  events: {
    'click .refreshEntityData': 'refreshEntityData',
    'click .deduplicateSubEntities': 'deduplicateSubEntities'
  },

  refreshEntityData () { app.execute('show:entity:refresh', this.view.model) },
  deduplicateSubEntities () { app.execute('show:deduplicate:sub:entities', this.view.model) }
})
