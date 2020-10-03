import { clickCommand } from 'lib/utils'
export default Marionette.ItemView.extend({
  className: 'inventoryWelcome',
  template: require('./templates/inventory_welcome.hbs'),

  events: {
    'click a[href="/add"]': clickCommand('show:add:layout:search')
  },

  behaviors: {
    PreventDefault: {}
  }
})
