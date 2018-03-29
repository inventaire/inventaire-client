{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'
error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  className: 'import-queue'
  template: require './templates/import_queue'
  childViewContainer: '#candidatesQueue'
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
    'click #selectAll': 'selectAll'
    'click #unselectAll': 'unselectAll'
    'click #emptyQueue': 'emptyQueue'
    'click #validate': 'validate'

  initialize: ->
    @lazyUpdateLastStep = _.debounce @updateLastStep.bind(@), 200

  onShow: ->
    @lazyUpdateLastStep()

  selectAll: ->
    @collection.setAllSelectedTo true
    @updateLastStep()

  unselectAll: ->
    @collection.setAllSelectedTo false
    @updateLastStep()

  emptyQueue: ->
    @collection.reset()

  childEvents:
    'selection:changed': 'lazyUpdateLastStep'

  collectionEvents:
    'add': 'lazyUpdateLastStep'

  updateLastStep: ->
    if @collection.selectionIsntEmpty()
      @ui.disabledValidateButton.addClass 'force-hidden'
      @ui.validateButton.removeClass 'force-hidden'
      @ui.lastSteps.removeClass 'disabled'
    else
      # Use 'force-hidden' as the class 'button' would otherwise overrides
      # the 'display' attribute
      @ui.validateButton.addClass 'force-hidden'
      @ui.disabledValidateButton.removeClass 'force-hidden'
      @ui.lastSteps.addClass 'disabled'

  validate: ->
    @toggleValidationElements()
    @selected = @collection.getSelected()
    @total = @selected.length
    transaction = getSelectorData @, 'transaction'
    listing = getSelectorData @, 'listing'
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
      @updateLastStep()
      _.log @failed, 'failed candidates imports'
      @collection.add @failed
      # Hide the cant import message now
      # as it might sound like the import failed.
      # The section will not be empty though, thank to the addedItems message
      # on the import layout.
      # Has to happen after updateLastStep as it will trigger
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
