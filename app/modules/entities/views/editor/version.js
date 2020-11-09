import versionTemplate from './templates/version.hbs'

export default Marionette.ItemView.extend({
  className: 'version',
  template: versionTemplate,
  initialize () {},

  serializeData () { return this.model.serializeData() },

  modelEvents: {
    grab: 'lazyRender'
  }
})
