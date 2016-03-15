itemCreationData = require 'modules/inventory/lib/item_creation_data'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'

module.exports = Marionette.CompositeView.extend
  className: 'import-queue'
  template: require './templates/import_queue'
  childViewContainer: 'tbody'
  childView: require './candidate_row'

  ui:
    headCheckbox: 'thead input'

  behaviors:
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect

  serializeData: ->
    listings: itemCreationData.listingsData()
    transactions: itemCreationData.transactionsData()

  events:
    'change th.selected input': 'toggleAll'

  initialize: ->
    _.inspect @, 'import view'


  toggleAll: (e)->
    if e.currentTarget.checked then @selectAll()
    else @unselectAll()

  selectAll: -> @changeAll true
  unselectAll: -> @changeAll false
  changeAll: (bool)->
    @collection.forEach (model)-> model.set 'selected', bool

  childEvents:
    'checkbox:change': 'updateHeadCheckbox'

  updateHeadCheckbox: ->
    selectedCount = @collection.map(convertSelectedToNumber).sum()
    if selectedCount is 0
      @ui.headCheckbox.prop 'checked', false
    else if selectedCount is @collection.length
      @ui.headCheckbox.prop 'checked', true
    else
      @ui.headCheckbox.prop 'indeterminate', true

convertSelectedToNumber = (model)-> if model.get('selected') then 1 else 0
