module.exports = class Inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/items/templates/inventory'
  regions:
    topMenu: '#topmMenu'
    viewTools: '#viewTools'
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  events:
    'click #addItem': 'showItemCreationForm'
    'keyup #itemsTextFilterField': -> app.commands.execute 'textFilter', $('#itemsTextFilterField').val()
    'click #itemsTextFilterButton': -> app.commands.execute 'textFilter', $('#itemsTextFilterField').val()
    'keyup #contactSearchField': -> app.commands.execute 'contactSearch', $('#contactSearchField').val()
    'click #contactSearchButton': -> app.commands.execute 'contactSearch', $('#contactSearchField').val()

    # FILTER
    'click #noVisibilityFilter': 'updateVisibilityTabs'
    'click #private': 'updateVisibilityTabs'
    'click #contacts': 'updateVisibilityTabs'
    'click #public': 'updateVisibilityTabs'

  onShow: ->
    app.inventory.topMenu.show new app.View.InventoriesTabs
    app.commands.execute 'personalInventory'

  showItemCreationForm: ->
    app.layout.modal.show new app.View.ItemCreationForm

  ######### VISIBILITY FILTER #########
  updateVisibilityTabs: (e)->
    visibility = $(e.currentTarget).attr('id')
    if visibility is 'noVisibilityFilter'
      app.commands.execute 'filter:visibility:reset'
    else
      app.commands.execute 'filter:visibility', visibility

    $('#visibility-tabs li').removeClass('active')
    $(e.currentTarget).find('li').addClass('active')



