export default Marionette.Behavior.extend({
  events: {
    'click .refreshEntityData': 'refreshEntityData',
    'click .deduplicateSubEntities': 'deduplicateSubEntities'
  },

  refreshEntityData() { return app.execute('show:entity:refresh', this.view.model); },
  deduplicateSubEntities() { return app.execute('show:deduplicate:sub:entities', this.view.model); }
});
