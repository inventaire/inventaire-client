/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import NoItem from './no_item'

export default Marionette.ItemView.extend({
  className: 'inventoryWelcome',
  template: require('./templates/inventory_welcome'),

  events: {
    'click a[href="/add"]': _.clickCommand('show:add:layout:search')
  },

  behaviors: {
    PreventDefault: {}
  }
})
