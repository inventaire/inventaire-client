module.exports = class InventoriesTabs extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/inventories_tabs'

  events:
    'click #personalInventory': -> app.execute 'personalInventory'
    'click #networkInventory': -> app.execute 'networkInventory'
    'click #publicInventory': -> app.execute 'publicInventory'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      $('#inventoriesTabs').find('.active').removeClass('active')
      $("##{filterName}").parent().addClass('active')