import { clickCommand } from 'lib/utils'
import inventoryWelcomeTemplate from './templates/inventory_welcome.hbs'

export default Marionette.ItemView.extend({
  className: 'inventoryWelcome',
  template: inventoryWelcomeTemplate,

  events: {
    'click a[href="/add"]': clickCommand('show:add:layout:search')
  },

  behaviors: {
    PreventDefault: {}
  }
})
