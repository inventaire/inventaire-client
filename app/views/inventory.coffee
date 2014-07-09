app = require 'app'

module.exports = class InventoryView extends Backbone.Marionette.ItemView
  id: 'inventory'
  template: require 'views/templates/inventory'
  events:
    # TABS
    'click #personalInventory': 'filterByInventoryType'
    'click #networkInventories': 'filterByInventoryType'
    'click #publicInventories': 'filterByInventoryType'

    # VIEW MODE
    'click #listView': 'renderListView'
    'click #gridView': 'renderGridView'

    # FILTER
    'keyup #searchfield': 'searchItems'
    'click #noVisibilityFilter': 'updateVisibilityTabs'
    'click #private': 'updateVisibilityTabs'
    'click #contacts': 'updateVisibilityTabs'
    'click #public': 'updateVisibilityTabs'


  ############### VIEW MODE #############
  renderListView: ->
    $('.viewmode').removeClass('active')
    $('#listView').parent().addClass('active')
    window.filteredItems = @filteredItems
    list = new ItemList @filteredItems

  renderGridView: ->
    $('.viewmode').removeClass('active')
    $('#gridView').parent().addClass('active')
    grid = new Backgrid.Grid
      columns: ColumnsTemplate
      collection: @items
    $("#itemsView").html(grid.render().el)
    return @

  ############# FILTER MODE #############

  searchItems: (text)->
    @textFilter $('#searchfield').val()

  textFilter: (text)->
    if text.length != 0
      filterExpr = new RegExp text, "i"
      @filteredItems.filterBy 'text', (model)->
        return model.matches filterExpr
    else
      @filteredItems.removeFilter 'text'
    @refresh()

  refresh: ->
    @renderListView()
    if filteredItems.length is 0
      $('#itemsView').append('<li class="text-center hidden">No item here</li>').find('li').fadeIn()

    if @filteredItems.hasFilter 'personalInventory'
      $('#visibility-tabs').show()
    else
      @setVisibilityFilter null
      $('#visibility-tabs').hide()

  ######### VISIBILITY FILTER #########
  updateVisibilityTabs: (e)->
    visibility = $(e.currentTarget).attr('id')
    if visibility is 'noVisibilityFilter'
      @setVisibilityFilter null
    else
      @setVisibilityFilter visibility
    @refresh()

    $('#visibility-tabs li').removeClass('active')
    $(e.currentTarget).find('li').addClass('active')

  visibilityFilters:
    'private': {'visibility':'private'}
    'contacts': {'visibility':'contacts'}
    'public': {'visibility':'public'}

  setVisibilityFilter: (audience)->
    otherFilters = _.without _.keys(@visibilityFilters), audience
    otherFilters.forEach (otherFilterName)->
      @filteredItems.removeFilter otherFilterName
    if audience?
      @filteredItems.filterBy audience, @visibilityFilters[audience]


############ TABS ############
  filterByInventoryType: (e)->
    inventoryType = $(e.currentTarget).attr('id')
    @filterInventoryBy inventoryType
    @refresh()
    @updateInventoriesTabs e

  updateInventoriesTabs: (e)->
    $('#inventoriesTabs').find('.active').removeClass('active')
    $(e.currentTarget).parent().addClass('active')

  inventoryFilters:
    'personalInventory': {'owner':'username'}
    'networkInventories': {'owner':'zombo'}
    'publicInventories': {'owner':'notUsername'}

  filterInventoryBy: (filterName)->
    otherFilters = _.without _.keys(@inventoryFilters), filterName
    otherFilters.forEach (otherFilterName)->
      @filteredItems.removeFilter otherFilterName
    @filteredItems.filterBy filterName, @inventoryFilters[filterName]