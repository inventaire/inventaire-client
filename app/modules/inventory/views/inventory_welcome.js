import { clickCommand } from 'lib/utils'
import inventoryWelcomeTemplate from './templates/inventory_welcome.hbs'
import '../scss/inventory_welcome.scss'
import PreventDefault from 'behaviors/prevent_default'

export default Marionette.View.extend({
  className: 'inventoryWelcome',
  template: inventoryWelcomeTemplate,

  events: {
    'click a[href="/add"]': clickCommand('show:add:layout:search')
  },

  behaviors: {
    PreventDefault,
  }
})
