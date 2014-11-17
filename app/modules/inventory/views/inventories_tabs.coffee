module.exports = class InventoriesTabs extends Backbone.Marionette.ItemView
  template: require './templates/inventories_tabs'

  events:
    'click #personal': -> app.execute 'show:inventory:personal'
    'click #friends': -> app.execute 'show:inventory:friends'
    'click #public': -> app.execute 'show:inventory:public'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      $('#inventoriesTabs').find('.active').removeClass('active')
      $("##{filterName}").parent().addClass('active')