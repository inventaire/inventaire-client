import PropertyEditor from './property_editor'
import propertiesEditorTemplate from './templates/properties_editor.hbs'

export default Marionette.CollectionView.extend({
  className: 'properties-editor',
  template: propertiesEditorTemplate,
  childView: PropertyEditor,
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

  onRender () {
    if (this.hasPropertiesShortlist) this.ui.showAllProperties.show()
  },

  showAllProperties () {
    this.filter = null
    this.render()
    this.ui.showAllProperties.hide()
  }
})
