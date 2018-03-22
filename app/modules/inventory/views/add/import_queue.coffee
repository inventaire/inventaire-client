{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'
error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  className: 'import-queue'
  template: require './templates/import_queue'
  childViewContainer: 'tbody'
  childView: require './candidate_row'

  ui:
    headCheckbox: 'thead input'
    validationElements: '.validation > div'
    validateButton: '#validate'
    disabledValidateButton: '#disabledValidate'
    transaction: '#transaction'
    listing: '#listing'
    meter: '.meter'
    fraction: '.fraction'
    lastSteps: '#lastSteps'

  behaviors:
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect
    AlertBox: {}
    Loading: {}

  serializeData: ->
    listings: listingsData()
    transactions: transactionsData()

  events:
    'change th.selected input': 'toggleAll'
    'click #emptyQueue': 'emptyQueue'
    'click #validate': 'validate'

  initialize: ->
    @lazyUpdateHeadCheckbox = _.debounce @updateHeadCheckbox.bind(@), 200

  toggleAll: (e)->
    if e.currentTarget.checked then @selectAll()
    else @unselectAll()

  selectAll: ->
    @collection.setAllSelectedTo true
    @onSelectionChange @collection.getSelectedCount()

  unselectAll: ->
    @collection.setAllSelectedTo false
    @onSelectionChange 0

  emptyQueue: ->
    @collection.reset()

  childEvents:
    'checkbox:change': 'lazyUpdateHeadCheckbox'

  collectionEvents:
    'add': 'lazyUpdateHeadCheckbox'

  updateHeadCheckbox: ->
    selectedCount = @collection.getSelectedCount()
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
    if selectedCount is 0
      # Use 'force-hidden' as the class 'button' would otherwise overrides
      # the 'display' attribute
      @ui.validateButton.addClass 'force-hidden'
      @ui.disabledValidateButton.removeClass 'force-hidden'
      @ui.lastSteps.addClass 'disabled'
    else
      @ui.disabledValidateButton.addClass 'force-hidden'
      @ui.validateButton.removeClass 'force-hidden'
      @ui.lastSteps.removeClass 'disabled'

  validate: ->
    @toggleValidationElements()
    @selected = @collection.getSelected()
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
      .catch (err)=>
        candidate.set 'errorMessage', err.message
        @failed or= []
        @failed.push candidate
        return
      .then (item)=>
        @collection.remove candidate
        # recursively trigger next import
        @chainedImport transaction, listing

      .catch error_.Complete('.validation')
      .catch forms_.catchAlert.bind(null, @)

    else
      _.log 'done importing!'
      @stopProgressUpdate()
      @toggleValidationElements()
      @updateHeadCheckbox()
      _.log @failed, 'failed candidates imports'
      @collection.add @failed
      # Hide the cant import message now
      # as it might sound like the import failed.
      # The section will not be empty though, thank to the addedItems message
      # on the import layout.
      # Has to happen after updateHeadCheckbox as it will trigger
      # onSelectionChange, which in turn could show cantValidateMessage
      @ui.cantValidateMessage.hide()
      # triggering events on the parent via childEvents
      @triggerMethod 'import:done'

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

convertSelectedToNumber = (model)-> if isSelected(model) then 1 else 0
isSelected = (model)-> model.get 'selected'
