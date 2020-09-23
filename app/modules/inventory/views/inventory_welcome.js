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
