export default Marionette.CompositeView.extend({
  className: 'properties-editor',
  template: require('./templates/properties_editor.hbs'),
  childView: require('./property_editor'),
  childViewContainer: '.properties',
  initialize () {
    const { propertiesShortlist } = this.options
    this.hasPropertiesShortlist = (propertiesShortlist != null)

    if (this.hasPropertiesShortlist) {
      // set propertiesShortlist to display only a subset of properties by default
      this.filter = function (child, index, collection) {
        return propertiesShortlist.includes(child.get('property'))
      }
    }
  },

  ui: {
    showAllProperties: '#showAllProperties'
  },

  events: {
    'click #showAllProperties': 'showAllProperties'
  },

  onShow () {
    if (this.hasPropertiesShortlist) this.ui.showAllProperties.show()
  },

  showAllProperties () {
    this.filter = null
    this.render()
    this.ui.showAllProperties.hide()
  }
})
