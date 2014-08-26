module.exports = class InventoriesTabs extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/inventories_tabs'

  events:
    'click #personalInventory': -> app.execute 'show:inventory:personal'
    'click #networkInventory': -> app.execute 'show:inventory:network'
    'click #publicInventory': -> app.execute 'show:inventory:public'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      $('#inventoriesTabs').find('.active').removeClass('active')
      $("##{filterName}").parent().addClass('active')