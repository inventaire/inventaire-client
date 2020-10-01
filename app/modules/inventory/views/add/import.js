import files_ from 'lib/files'
import importers from '../../lib/importers'
import dataValidator from '../../lib/data_validator'
import ImportQueue from './import_queue'
import Candidates from '../../collections/candidates'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import screen_ from 'lib/screen'
import commonParser from '../../lib/parsers/common'
import extractIsbnsAndFetchData from '../../lib/import/extract_isbns_and_fetch_data'
const papaparse = require('lib/get_assets')('papaparse')
const isbn2 = require('lib/get_assets')('isbn2')

let candidates = null

export default Marionette.LayoutView.extend({
  id: 'importLayout',
  template: require('./templates/import'),
  behaviors: {
    AlertBox: {},
    Loading: {},
    PreventDefault: {},
    SuccessCheck: {},
    ElasticTextarea: {}
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

  childEvents: {
    'import:done': 'onImportDone'
  },

  initialize () {
    ({ isbnsBatch: this.isbnsBatch } = this.options)

    isbn2.prepare()
    // No need to fetch papaparse if we know we will go straight
    // to the ISBN importer
    if (this.isbnsBatch != null) {
      this.hideImporters = true
    } else { papaparse.prepare() }

    return candidates || (candidates = new Candidates())
  },

  onShow () {
    // show the import queue if there were still candidates from last time
    this.showImportQueueUnlessEmpty()

    // Accept ISBNs from the URL to ease development
    const isbns = app.request('querystring:get', 'isbns')?.split('|')
    if (!this.isbnsBatch) { this.isbnsBatch = isbns }

    if (this.isbnsBatch != null) {
      this.ui.isbnsImporterTextarea.val(this.isbnsBatch.join('\n'))
      return this.$el.find('#findIsbns').trigger('click')
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
      if (!this.queue.hasView()) {
        this.queue.show(new ImportQueue({ candidates }))
      }

      // Run once @ui.importersWrapper is done sliding up
      return this.setTimeout(screen_.scrollTop.bind(null, this.queue.$el), 500)
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

    return Promise.all([
      files_.parseFileEventAsText(e, true, encoding),
      papaparse.get(),
      isbn2.get()
    ])
    // We only need the result from the file
    .spread(data => {
      dataValidator(source, data)
      return parse(data).map(commonParser)
    }).catch(_.ErrorRethrow('parsing error'))
    // add the selector to the rejected error
    // so that it can be catched by catchAlert
    .catch(error_.Complete('#importersWrapper .warning'))
    .then(_.Log('parsed'))
    .then(candidates.addNewCandidates.bind(candidates))
    .tap(() => stopLoading.call(this, selector))
    .then(this.showImportQueueUnlessEmpty.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
  },

  // passing the event to the AlertBox behavior
  hideAlertBox () { return this.$el.trigger('hideAlertBox') },

  onImportDone () {
    return this.$el.trigger('check')
  },

  findIsbns () {
    const text = this.ui.isbnsImporterTextarea.val()
    if (!_.isNonEmptyString(text)) { return }

    const selector = '#isbnsImporterWrapper .loading'

    startLoading.call(this, {
      selector,
      timeout: 'none',
      progressionEventName: 'progression:ISBNs'
    }
    )

    return extractIsbnsAndFetchData(text)
    .then(candidates.addNewCandidates.bind(candidates))
    .then(addedCandidates => {
      stopLoading.call(this, selector)
      if (addedCandidates.length > 0) {
        return this.showImportQueueUnlessEmpty()
      } else { throw error_.new('no ISBN found', 400) }
    }).catch(error_.Complete('#isbnsImporterWrapper .warning'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  emptyIsbns () {
    this.ui.isbnsImporterTextarea.val('')
    this.$el.trigger('elastic:textarea:update')
    return this.hideAlertBox()
  }
})
