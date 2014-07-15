module.exports = class Inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/templates/inventory'
  regions:
    itemsView: '#itemsView'
  events:

    'click #addItem': 'showItemCreationForm'

    # TABS
    'click #personalInventory': 'filterByInventoryType'
    'click #networkInventories': 'filterByInventoryType'
    'click #publicInventories': 'filterByInventoryType'

    # FILTER
  #   'keyup #searchfield': 'searchItems'@on 'childview:render', (data)->
    #   console.log "[itemslist:childview:render]"
    #   console.log data
    'click #noVisibilityFilter': 'updateVisibilityTabs'
    'click #private': 'updateVisibilityTabs'
    'click #contacts': 'updateVisibilityTabs'
    'click #public': 'updateVisibilityTabs'

  onShow: ->
    console.log 'INVENTORY SHOW'
    app.inventory.itemsList = itemsList = new app.View.ItemsList {collection: app.filteredItems}
    app.inventory.itemsView.show itemsList
    # console.dir app.filteredItems

  showItemCreationForm: ->
    app.layout.modal.show new app.View.ItemCreationForm


  # ############# FILTER MODE #############

  # searchItems: (text)->
  #   @textFilter $('#searchfield').val()

  # textFilter: (text)->
  #   if text.length != 0
  #     filterExpr = new RegExp text, "i"
  #     @filteredItems.filterBy 'text', (model)->
  #       return model.matches filterExpr
  #   else
  #     @filteredItems.removeFilter 'text'
  #   @refresh()

  # refresh: ->
  #   @renderListView()
  #   if filteredItems.length is 0
  #     $('#itemsView').append('<li class="text-center hidden">No item here</li>').find('li').fadeIn()

  #   if @filteredItems.hasFilter 'personalInventory'
  #     $('#visibility-tabs').show()
  #   else
  #     @setVisibilityFilter null
  #     $('#visibility-tabs').hide()

  ######### VISIBILITY FILTER #########
  updateVisibilityTabs: (e)->
    visibility = $(e.currentTarget).attr('id')
    if visibility is 'noVisibilityFilter'
      app.commands.execute 'filter:visibility:reset'
    else
      app.commands.execute 'filter:visibility', visibility
    console.log app.filteredItems.models
    # @refresh()

    $('#visibility-tabs li').removeClass('active')
    $(e.currentTarget).find('li').addClass('active')

############ TABS ############
  filterByInventoryType: (e)->
    inventoryType = $(e.currentTarget).attr('id')
    app.commands.execute 'filter:inventory', inventoryType
    # @refresh()
    console.log 'inventoryType'
    console.log inventoryType
    console.log 'app.filteredItems.models'
    console.log app.filteredItems.models
    @updateInventoriesTabs e

  updateInventoriesTabs: (e)->
    $('#inventoriesTabs').find('.active').removeClass('active')
    $(e.currentTarget).parent().addClass('active')