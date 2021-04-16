import { localStorageProxy } from 'lib/local_storage'
import displaySettingsTemplate from './templates/display_settings.hbs'

export default Marionette.ItemView.extend({
  template: displaySettingsTemplate,
  className: 'displaySettings',
  initialize () {
    this.entitiesDisplay = localStorageProxy.getItem('entitiesDisplay') || 'entitiesLargeList'
    this.inventoryDisplay = localStorageProxy.getItem('inventoryDisplay') || 'inventoryCascade'
  },

  serializeData () {
    const data = {}
    if (this.entitiesDisplay === 'compact') data.entitiesCompact = true
    else data.entitiesLarge = true
    if (this.inventoryDisplay === 'table') data.inventoryTable = true
    else data.inventoryCascade = true
    return data
  },

  events: {
    'change #entitiesDisplay': 'selectDisplay',
    'change #inventoryDisplay': 'selectDisplay'
  },

  selectDisplay (e) {
    const type = e.currentTarget.id
    const { value: newDisplay } = e.currentTarget
    localStorageProxy.setItem(type, newDisplay)
  }
})
