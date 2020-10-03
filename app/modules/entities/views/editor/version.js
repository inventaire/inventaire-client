export default Marionette.ItemView.extend({
  className: 'version',
  template: require('./templates/version.hbs'),
  initialize () {},

  serializeData () { return this.model.serializeData() },

  modelEvents: {
    grab: 'lazyRender'
  }
})
