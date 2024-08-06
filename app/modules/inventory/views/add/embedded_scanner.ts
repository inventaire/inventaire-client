import app from '#app/app'
import { icon } from '#app/lib/icons'
import log_ from '#app/lib/loggers'
import Loading from '#behaviors/loading'
import behaviorsPlugin from '#general/plugins/behaviors'
import embedded_ from '#inventory/lib/scanner/embedded'
import { I18n, i18n } from '#user/lib/i18n'
import embeddedScannerTemplate from './templates/embedded_scanner.hbs'
import '#inventory/scss/_embedded.scss'

export default Marionette.View.extend({
  template: embeddedScannerTemplate,
  className: 'embedded',
  behaviors: {
    Loading,
  },

  ui: {
    statusMessage: '.statusMessage',
    shadowAreaBox: '#shadowAreaBox',
    validate: '#validateScan',
    totalCounter: '#totalCounter',
    notFoundCounter: '#notFoundCounter',
    failing: '.failing',
  },

  events: {
    'click #closeScan': 'close',
    'click #validateScan': 'validate',
  },

  onRender () {
    this.displayAboveTopBar()
    // Removing the timeout on the loader as it depend on the time
    // the user takes to give the permission to access the camera
    behaviorsPlugin.startLoading.call(this, { timeout: 'none' })

    this.batch = []
    this.notFound = []

    const scanOptions = {
      beforeScannerStart: this.beforeScannerStart.bind(this),
      onDetectedActions: {
        addIsbn: this.addIsbn.bind(this),
        showInvalidIsbnWarning: this.showInvalidIsbnWarning.bind(this),
      },
      setStopScannerCallback: this.setStopScannerCallback.bind(this),
    }

    // Observed behavior: after refusing rights, the spinner keeps going
    // and an error report is sent with "message: 'invalid error object', context: { reason: 'permission_denied' }"
    // TODO: fix error catching and add a comment on how to give permission to access the camera
    this.scanner = embedded_.scan(scanOptions).catch(this.permissionDenied.bind(this))
  },

  beforeScannerStart () {
    this.ui.shadowAreaBox.removeClass('hidden')

    this.showStatusMessage({
      type: 'tip',
      message: I18n("make the book's barcode fit in the box"),
      // displayDelay: 1000
      displayTime: 29 * 1000,
    })

    this.showStatusMessage({
      message: I18n('failing_scan_tip'),
      type: 'support',
      displayDelay: 30 * 1000,
      // Display only if no ISBN, valid or not, was detected
      displayCondition: () => (this.batch.length === 0) && !this.invalidIsbnDetected,
      displayTime: 30 * 1000,
    })
  },

  addIsbn (isbn) {
    this._lastIsbn = isbn

    if (this.batch.includes(isbn)) this.showDuplicateIsbnWarning(isbn)

    this.batch.push(isbn)
    this.precachingEntityData(isbn)

    this._lastSuccessTime = Date.now()
    this.showStatusMessage({
      message: i18n('added:') + ' ' + isbn,
      type: 'success',
      displayTime: 4000,
    })

    this.updateCounter()

    if (this.batch.length === 1) {
      this.ui.validate.removeClass('hidden')
      // The shadow barcode shouldn't be needed anymore
      this.ui.shadowAreaBox.addClass('hidden')
      return this.initMultiBarcodeTip()
    }
  },

  precachingEntityData (isbn) {
    // Pre-requesting the entity's data to let the time to the server
    // to possibly fetch dataseeds, while we will only need the data later.
    // If successful, the entities will be pre-cached
    return app.request('get:entity:model', `isbn:${isbn}`)
    .catch(err => {
      if (err.message.match('entity_not_found')) {
        return this.updateNotFoundCounter(isbn)
      } else {
        throw err
      }
    })
    .catch(log_.Error('isbn batch pre-cache err'))
  },

  updateNotFoundCounter (isbn) {
    this.notFound.push(isbn)
    const notFoundCount = this.notFound.length
    if (notFoundCount === 1) this.ui.notFoundCounter?.parent().removeClass('hidden')
    this.ui.notFoundCounter?.text(notFoundCount)
  },

  showDuplicateIsbnWarning (isbn) {
    const now = Date.now()
    if (this._lastSuccessTime == null) this._lastSuccessTime = 0
    if (this._lastDuplicate == null) this._lastDuplicate = 0

    const differentIsbn = isbn !== this._lastIsbn
    // Do not show to soon after the successful scan
    // and debounce duplicate messages
    const debounced = ((now - this._lastSuccessTime) > 5000) && ((now - this._lastDuplicate) > 3000)

    if (differentIsbn || debounced) {
      this._lastDuplicate = Date.now()
      this.showStatusMessage({
        message: I18n('this ISBN was already scanned'),
        type: 'warning',
        displayTime: 2000,
      })
    }
  },

  initMultiBarcodeTip () {
    this.showStatusMessage({
      message: I18n('multi_barcode_scan_tip'),
      type: 'tip',
      // Show the tip once the success message is over
      displayDelay: 2000,
      // Do not display if already several ISBNs were scanned
      displayCondition: () => this.batch.length === 1,
      displayTime: 5000,
    })
  },

  showStatusMessage (params) {
    const { message, type, displayDelay, displayCondition, displayTime } = params

    const showMessage = () => {
      if (this.isDestroyed()) return
      if ((displayCondition != null) && !displayCondition()) return

      this.ui.statusMessage.html(icon(iconPerType[type]) + message)
      .addClass('shown')
      // Used as a CSS selector
      .attr('data-type', type)

      this._lastMessage = message

      const hideMessage = () => {
        if (this.isDestroyed() || (this._lastMessage !== message)) return
        this.ui.statusMessage.removeClass('shown')
      }

      this.setTimeout(hideMessage, displayTime)
    }

    if (displayDelay != null) {
      this.setTimeout(showMessage, displayDelay)
    } else {
      return showMessage()
    }
  },

  showInvalidIsbnWarning (invalidIsbn) {
    this.showStatusMessage({
      message: i18n('invalid ISBN') + ': ' + invalidIsbn,
      type: 'warning',
      displayTime: 5000,
    })
  },

  updateCounter () {
    // Prevent crashing with a 'TypeError: this.ui.totalCounter.text is not a function' error
    if (this.isDestroyed()) return
    this.ui.totalCounter.text(`(${this.batch.length})`)
    this.ui.validate.addClass('flash')
    this.setTimeout(this.ui.validate.removeClass.bind(this.ui.validate, 'flash'), 1000)
  },

  permissionDenied (err) {
    if (err.reason === 'permission_denied') {
      log_.info('permission denied: closing scanner')
    } else {
      log_.error(err, 'scan error')
    }

    // In any case, close
    return this.close()
  },

  validate () { app.execute('show:add:layout:import:isbns', this.batch) },

  close () {
    // come back to the previous view
    // which should trigger @destroy as the previous view is expected to be shown
    // in app.layout.getRegion('main') too
    return window.history.back()
  },

  setStopScannerCallback (fn) { this.stopScanner = fn },

  onDestroy () {
    this.stopScanner?.()
    this.resetDisplay()
  },

  displayAboveTopBar () {
    app.layout.getRegion('main').$el.css('z-index', '2')
  },

  resetDisplay () {
    app.layout.getRegion('main').$el.css('z-index', '0')
  },
})

const iconPerType = {
  success: 'check',
  support: 'support',
  tip: 'info-circle',
  warning: 'warning',
}
