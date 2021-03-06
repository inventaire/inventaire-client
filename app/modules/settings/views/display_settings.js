import { localStorageProxy } from 'lib/local_storage'
import displaySettingsTemplate from './templates/display_settings.hbs'

export default Marionette.ItemView.extend({
  template: displaySettingsTemplate,
  className: 'displaySettings',
  initialize () {
    this.entitiesDisplay = localStorageProxy.getItem('entitiesDisplay') || 'entitiesCascade'
    this.inventoryDisplay = localStorageProxy.getItem('inventoryDisplay') || 'inventoryCascade'
  },

  serializeData () {
    const data = {}
    data[this.entitiesDisplay] = true
    data[this.inventoryDisplay] = true
    return data
  },

  events: {
    'click #entitiesDisplayOptions li': 'selectDisplay',
    'click #inventoryDisplayOptions li': 'selectDisplay'
  },

  selectDisplay (e) {
    const newDisplay = e.currentTarget.id
    const type = e.currentTarget.attributes['data-display-type'].value
    if (newDisplay === this[type]) { return }
    this[type] = newDisplay
    this.lazyRender()
    return localStorageProxy.setItem(type, newDisplay)
  }
})
