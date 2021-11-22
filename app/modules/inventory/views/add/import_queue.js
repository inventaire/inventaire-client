import log_ from 'lib/loggers'
import { listingsData, transactionsData, getSelectorData } from 'modules/inventory/lib/item_creation'
import error_ from 'lib/error'
import forms_ from 'modules/general/lib/forms'
import screen_ from 'lib/screen'
import ItemShelves from '../item_shelves'
import { getShelvesByOwner } from 'modules/shelves/lib/shelves'
import Shelves from 'modules/shelves/collections/shelves'
import CandidateRow from './candidate_row'
import ImportedItemRow from './imported_item_row'
import importQueueTemplate from './templates/import_queue.hbs'
import 'modules/inventory/scss/item_creation_commons.scss'
import 'modules/inventory/scss/import_queue.scss'
import AlertBox from 'behaviors/alert_box'
import Loading from 'behaviors/loading'
import UpdateSelector from 'modules/inventory/behaviors/update_selector'

const CandidatesQueue = Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: CandidateRow,
  childViewEvents: {
    'selection:changed' () { this.triggerMethod('selection:changed') }
  }
})

const ImportedItemsList = Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: ImportedItemRow
})

export default Marionette.View.extend({
  className: 'import-queue',
  template: importQueueTemplate,

  regions: {
    candidatesQueue: '#candidatesQueue',
    itemsList: '#itemsList',
    shelvesSelector: '#shelvesSelector'
  },

  ui: {
    headCheckbox: 'thead input',
    validationElements: '.import, .progress-bar',
    validateButton: '#validate',
    disabledValidateButton: '#disabledValidate',
    transaction: '#transaction',
    listing: '#listing',
    meter: '.meter',
    fraction: '.fraction',
    step2: '#step2',
    lastSteps: '#lastSteps',
    addedBooks: '#addedBooks',
    shelvesWrapper: '#shelvesWrapper'
  },

  behaviors: {
    AlertBox,
    Loading,
    UpdateSelector,
  },

  events: {
    'change th.selected input': 'toggleAll',
    'click #selectAll': 'selectAll',
    'click #unselectAll': 'unselectAll',
    'click #emptyQueue': 'emptyQueue',
    'click #validate': 'validate'
  },

  initialize () {
    this.candidates = this.options.candidates
    this.items = new Backbone.Collection()
    this.lazyUpdateSteps = _.debounce(this.updateSteps.bind(this), 50)
  },

  serializeData () {
    return {
      listings: listingsData(),
      transactions: transactionsData()
    }
  },

  onShow () {
    this.showChildView('candidatesQueue', new CandidatesQueue({ collection: this.candidates }))
    this.showChildView('itemsList', new ImportedItemsList({ collection: this.items }))
    this.lazyUpdateSteps()
    this.showShelves()
  },

  selectAll () {
    this.candidates.setAllSelectedTo(true)
    return this.updateSteps()
  },

  unselectAll () {
    this.candidates.setAllSelectedTo(false)
    return this.updateSteps()
  },

  emptyQueue () {
    return this.candidates.reset()
  },

  childViewEvents: {
    'selection:changed': 'lazyUpdateSteps'
  },

  collectionEvents: {
    add: 'lazyUpdateSteps'
  },

  updateSteps () {
    if (this.candidates.selectionIsntEmpty()) {
      this.ui.disabledValidateButton.addClass('force-hidden')
      this.ui.validateButton.removeClass('force-hidden')
      this.ui.lastSteps.removeClass('force-hidden')
    } else {
      // Use 'force-hidden' as the class 'button' would otherwise overrides
      // the 'display' attribute
      this.ui.validateButton.addClass('force-hidden')
      this.ui.disabledValidateButton.removeClass('force-hidden')
      this.ui.lastSteps.addClass('force-hidden')
    }

    if (this.candidates.length === 0) {
      this.ui.step2.addClass('force-hidden')
    } else {
      this.ui.step2.removeClass('force-hidden')
    }
  },

  showShelves () {
    return getShelvesByOwner(app.user.id)
    .then(this.ifViewIsIntact('_showShelves'))
    .catch(log_.Error('showShelves err'))
  },

  _showShelves (shelves) {
    const selectedShelves = app.request('last:shelves:get') || []
    // TODO: offer to create shelves from this form instead
    if (shelves.length > 0) {
      const collection = new Shelves(shelves, { selected: selectedShelves })
      this.showChildView('shelvesSelector', new ItemShelves({
        collection,
        selectedShelves,
        mainUserIsOwner: true
      }))
      this.ui.shelvesWrapper.removeClass('hidden')
    }
  },

  getSelectedShelves () {
    const selectedShelves = this.$el.find('.shelfSelector input')
      .filter((i, el) => el.checked)
      .map((i, el) => el.name.split('-')[1])
    return Array.from(selectedShelves)
  },

  validate () {
    this.toggleValidationElements()

    this.selected = this.candidates.getSelected()
    this.total = this.selected.length

    const transaction = getSelectorData(this, 'transaction')
    const listing = getSelectorData(this, 'listing')
    const shelves = this.getSelectedShelves()

    app.execute('last:shelves:set', shelves)

    this.chainedImport(transaction, listing, shelves)
    this.planProgressUpdate()
  },

  chainedImport (transaction, listing, shelves) {
    if (this.selected.length === 0) return this.doneImporting()

    const candidate = this.selected.pop()
    return candidate.createItem({ transaction, listing, shelves })
    .catch(err => {
      candidate.set('errorMessage', err.message)
      if (!this.failed) this.failed = []
      this.failed.push(candidate)
      log_.error(err, 'chainedImport err')
    })
    .then(item => {
      this.candidates.remove(candidate)
      if (item != null) {
        this.items.add(item)
        // Show the added books on the first successful import
        if (!this._shownAddedBooks) {
          this._shownAddedBooks = true
          this.setTimeout(this.showAddedBooks.bind(this), 1000)
        }
      }
      // recursively trigger next import
      return this.chainedImport(transaction, listing)
    })
    .catch(error_.Complete('.validation'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  doneImporting () {
    log_.info('done importing!')
    this.stopProgressUpdate()
    this.toggleValidationElements()
    this.updateSteps()
    if (this.failed?.length > 0) {
      log_.info(this.failed, 'failed candidates imports')
      this.candidates.add(this.failed)
      this.failed = []
    }
    // triggering events on the parent via childViewEvents
    this.triggerMethod('import:done')
  },

  showAddedBooks () {
    this.ui.addedBooks.fadeIn()
    this.setTimeout(screen_.scrollTop.bind(null, this.ui.addedBooks), 600)
  },

  toggleValidationElements () {
    this.ui.validationElements.toggleClass('force-hidden')
  },

  planProgressUpdate () {
    // Using a recursive timeout instead of an interval
    // to avoid trying to update after a failed attempt
    // Typically occurring when the view as been destroyed
    this.timeoutId = setTimeout(this.updateProgress.bind(this), 1000)
  },

  stopProgressUpdate () {
    return clearTimeout(this.timeoutId)
  },

  updateProgress () {
    const remaining = this.selected.length
    const added = this.total - remaining
    const percent = (added / this.total) * 100
    this.ui.meter.css('width', `${percent}%`)
    this.ui.fraction.text(`${added} / ${this.total}`)
    this.planProgressUpdate()
  },

  onDestroy () { return this.stopProgressUpdate() }
})
