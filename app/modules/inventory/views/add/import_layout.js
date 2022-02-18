import { isNonEmptyString } from '#lib/boolean_tests'
import log_ from '#lib/loggers'
import files_ from '#lib/files'
import importers from '../../lib/importers'
import dataValidator from '../../lib/data_validator'
import ImportQueue from './import_queue.js'
import Candidates from '../../collections/candidates'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import screen_ from '#lib/screen'
import commonParser from '../../lib/parsers/common'
import extractIsbnsAndFetchData from '../../lib/import/extract_isbns_and_fetch_data'
import importTemplate from './templates/import_layout.hbs'
import '#inventory/scss/import_layout.scss'
import AlertBox from '#behaviors/alert_box'
import ElasticTextarea from '#behaviors/elastic_textarea'
import Loading from '#behaviors/loading'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'

let candidates = null

export default Marionette.View.extend({
  id: 'importLayout',
  template: importTemplate,
  behaviors: {
    AlertBox,
    ElasticTextarea,
    Loading,
    PreventDefault,
    SuccessCheck,
  },

  regions: {
    queue: '#queue'
  },

  ui: {
    isbnsImporter: '#isbnsImporter',
    isbnsImporterTextarea: '#isbnsImporter textarea',
    isbnsImporterWrapper: '#isbnsImporterWrapper',
    importersWrapper: '#importersWrapper'
  },

  events: {
    'change input[type=file]': 'getFile',
    'click input': 'hideAlertBox',
    'click #findIsbns': 'findIsbns',
    'click #emptyIsbns': 'emptyIsbns'
  },

  childViewEvents: {
    'import:done': 'onImportDone'
  },

  initialize () {
    this.isbnsBatch = this.options.isbnsBatch

    if (this.isbnsBatch != null) {
      this.hideImporters = true
    }

    candidates = candidates || new Candidates()
  },

  onRender () {
    // show the import queue if there were still candidates from last time
    this.showImportQueueUnlessEmpty()

    // Accept ISBNs from the URL to ease development
    const isbns = app.request('querystring:get', 'isbns')?.split('|')
    if (!this.isbnsBatch) this.isbnsBatch = isbns

    if (this.isbnsBatch != null) {
      this.ui.isbnsImporterTextarea.val(this.isbnsBatch.join('\n'))
      this.$el.find('#findIsbns').trigger('click')
    }
  },

  serializeData () {
    return {
      importers,
      hideImporters: this.hideImporters
    }
  },

  showImportQueueUnlessEmpty () {
    if (candidates.length > 0) {
      if (!this.getRegion('queue').hasView()) {
        this.showChildView('queue', new ImportQueue({ candidates }))
      }

      // Run once @ui.importersWrapper is done sliding up
      this.setTimeout(screen_.scrollTop.bind(null, this.getRegion('queue').$el), 500)
    }
  },

  getFile (e) {
    const source = e.currentTarget.id
    const { name, parse, encoding } = importers[source]

    const selector = `#${name}-li .loading`

    startLoading.call(this, {
      selector,
      timeout: 'none',
      progressionEventName: name === 'ISBNs' ? 'progression:ISBNs' : undefined
    })

    // TODO: refactor by turning parsers into async functions
    // which import their dependencies themselves
    return Promise.all([
      files_.parseFileEventAsText(e, true, encoding),
      import('papaparse'),
      import('isbn3'),
    ])
    // We only need the result from the file
    .then(([ data, { default: Papa }, { default: ISBN } ]) => {
      window.ISBN = ISBN
      window.Papa = Papa
      dataValidator(source, data)
      return parse(data).map(commonParser)
    })
    .catch(log_.ErrorRethrow('parsing error'))
    // add the selector to the rejected error
    // so that it can be catched by catchAlert
    .catch(error_.Complete('#importersWrapper .warning'))
    .then(log_.Info('parsed'))
    .then(candidates.addNewCandidates.bind(candidates))
    .finally(() => stopLoading.call(this, selector))
    .then(this.showImportQueueUnlessEmpty.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
  },

  // passing the event to the AlertBox behavior
  hideAlertBox () { this.$el.trigger('hideAlertBox') },

  onImportDone () {
    this.$el.trigger('check')
  },

  findIsbns () {
    const text = this.ui.isbnsImporterTextarea.val()
    if (!isNonEmptyString(text)) return

    const selector = '#isbnsImporterWrapper .loading'

    startLoading.call(this, {
      selector,
      timeout: 'none',
      progressionEventName: 'progression:ISBNs'
    })

    return extractIsbnsAndFetchData(text)
    .then(candidates.addNewCandidates.bind(candidates))
    .then(addedCandidates => {
      stopLoading.call(this, selector)
      if (addedCandidates.length > 0) {
        this.showImportQueueUnlessEmpty()
      } else {
        throw error_.new('no new ISBN found', 400)
      }
    })
    .catch(error_.Complete('#isbnsImporterWrapper .warning'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  emptyIsbns () {
    this.ui.isbnsImporterTextarea.val('')
    this.$el.trigger('elastic:textarea:update')
    this.hideAlertBox()
  }
})
