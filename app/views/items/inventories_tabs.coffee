module.exports = class InventoriesTabs extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/inventories_tabs'

  events:
    'click #personalInventory': -> app.commands.execute 'personalInventory'
    'click #networkInventories': -> app.commands.execute 'networkInventories'
    'click #publicInventories': -> app.commands.execute 'publicInventories'
    'click a': 'updateInventoriesTabs'

  updateInventoriesTabs: (e)->
    $('#inventoriesTabs').find('.active').removeClass('active')
    $(e.currentTarget).parent().addClass('active')