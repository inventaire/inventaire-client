{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'

module.exports = Marionette.CompositeView.extend
  className: 'import-queue'
  template: require './templates/import_queue'
  childViewContainer: 'tbody'
  childView: require './candidate_row'

  ui:
    headCheckbox: 'thead input'
    validationElements: '.validation > div'
    validateButton: '#validate'
    cantValidateMessage: '.import span'
    transaction: '#transaction'
    listing: '#listing'
    meter: '.meter'
    fraction: '.fraction'
    addedItems: '#addedItems'

  behaviors:
    PreventDefault: {}
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect

  serializeData: ->
    listings: listingsData()
    transactions: transactionsData()
    inventory: app.user.get('pathname')

  events:
    'change th.selected input': 'toggleAll'
    'click #validate': 'validate'
    'click #addedItems': 'showMainUserInventory'

  initialize: ->
    @lazyUpdateHeadCheckbox = _.debounce @updateHeadCheckbox.bind(@), 200

  toggleAll: (e)->
    if e.currentTarget.checked then @selectAll()
    else @unselectAll()

  selectAll: ->
    @changeAll true
    @onSelectionChange @collection.length

  unselectAll: ->
    @changeAll false
    @onSelectionChange 0

  changeAll: (bool)->
    @collection.forEach (model)-> model.set 'selected', bool

  childEvents:
    'checkbox:change': 'lazyUpdateHeadCheckbox'

  collectionEvents:
    'add': 'lazyUpdateHeadCheckbox'

  updateHeadCheckbox: ->
    selectedCount = @collection.map(convertSelectedToNumber).sum()
    if selectedCount is 0
      @applyCheckState false, false
    else if selectedCount is @collection.length
      @applyCheckState true, false
    else
      @applyCheckState false, true

    @onSelectionChange selectedCount

  applyCheckState: (checked, indeterminate)->
    @ui.headCheckbox
    .prop 'checked', checked
    # it seems that setting indeterminate to false is required
    # once it was set to true to make the checked state visible
    .prop 'indeterminate', indeterminate

  onSelectionChange: (selectedCount)->
    if selectedCount is 0 then @showCantValidateMessage()
    else @showValidateButton()

  validate: ->
    @toggleValidationElements()
    @selected = @collection.filter isSelected
    @total = @selected.length
    transaction = getSelectorData @, 'transaction'
    listing = getSelectorData @, 'listing'
    _.log @selected, '@selected'
    _.log transaction, 'transaction'
    _.log listing, 'listing'
    @chainedImport transaction, listing
    @startProgressUpdate()

  chainedImport: (transaction, listing)->
    if @selected.length > 0
      candidate = @selected.pop()
      candidate.createItem transaction, listing
      .then (item)=>
        @collection.remove candidate
        # recursively trigger next import
        @chainedImport transaction, listing

      .catch _.ErrorRethrow('chainedImport')

    else
      _.log 'done importing!'
      @stopProgressUpdate()
      @toggleValidationElements()
      @ui.addedItems.show()
      # Hide the cant import message now
      # as it might sound like the import failed.
      # The section will not be empty though, thank to
      # the addedItems cantValidateMessage
      # @ui.cantValidateMessage.hide()
      @lazyUpdateHeadCheckbox()

  showValidateButton: ->
    @ui.validateButton.show()
    @ui.cantValidateMessage.hide()

  showCantValidateMessage: ->
    @ui.validateButton.hide()
    @ui.cantValidateMessage.show()

  toggleValidationElements: ->
    @ui.validationElements.toggleClass 'force-hidden'

  startProgressUpdate: ->
    @intervalId = setInterval @updateProgress.bind(@), 1000
  stopProgressUpdate: ->
    clearInterval @intervalId

  updateProgress: ->
    remaining = @selected.length
    added = @total - remaining
    percent = (added / @total) * 100
    @ui.meter.css 'width', "#{percent}%"
    @ui.fraction.text "#{added} / #{@total}"

  showMainUserInventory: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:main:user'

convertSelectedToNumber = (model)-> if isSelected(model) then 1 else 0
isSelected = (model)-> model.get 'selected'
