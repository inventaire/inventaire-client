export default Marionette.ItemView.extend({
  className: 'version',
  template: require('./templates/version'),
  initialize() {},

  serializeData() { return this.model.serializeData(); },

  modelEvents: {
    'grab': 'lazyRender'
  }
});
