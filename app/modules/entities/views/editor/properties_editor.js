import PropertyEditor from './property_editor'
import propertiesEditorTemplate from './templates/properties_editor.hbs'

export default Marionette.CompositeView.extend({
  className: 'properties-editor',
  template: propertiesEditorTemplate,
  childView: PropertyEditor,
  childViewContainer: '.properties',
  initialize () {
    const propertiesShortlist = getPropertiesShortlistPerRole(this.options.propertiesShortlist)
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

const dataadminOnlyShortlistedProperties = [
  'wdt:P31'
]

const getPropertiesShortlistPerRole = propertiesShortlist => {
  if (!propertiesShortlist) return
  if (app.user.hasDataadminAccess) return propertiesShortlist
  else return _.without(propertiesShortlist, ...dataadminOnlyShortlistedProperties)
}
