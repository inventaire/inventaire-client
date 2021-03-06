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
    'change #entitiesDisplay': 'selectDisplay',
    'change #inventoryDisplay': 'selectDisplay'
  },

  selectDisplay (e) {
    const type = e.currentTarget.id
    const { value: newDisplay } = e.currentTarget
    return localStorageProxy.setItem(type, newDisplay)
  }
})
