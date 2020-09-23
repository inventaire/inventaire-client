import embedded_ from 'modules/inventory/lib/scanner/embedded';
import behaviorsPlugin from 'modules/general/plugins/behaviors';

export default Marionette.ItemView.extend({
  template: require('./templates/embedded_scanner'),
  className: 'embedded',
  behaviors: {
    Loading: {}
  },

  ui: {
    statusMessage: '.statusMessage',
    shadowAreaBox: '#shadowAreaBox',
    validate: '#validateScan',
    totalCounter: '#totalCounter',
    notFoundCounter: '#notFoundCounter',
    failing: '.failing'
  },

  events: {
    'click #closeScan': 'close',
    'click #validateScan': 'validate'
  },

  onShow() {
    app.execute('last:add:mode:set', 'scan:embedded');
    // Removing the timeout on the loader as it depend on the time
    // the user takes to give the permission to access the camera
    behaviorsPlugin.startLoading.call(this, { timeout: 'none' });

    this.batch = [];
    this.notFound = [];

    const scanOptions = {
      beforeScannerStart: this.beforeScannerStart.bind(this),
      onDetectedActions: {
        addIsbn: this.addIsbn.bind(this),
        showInvalidIsbnWarning: this.showInvalidIsbnWarning.bind(this)
      },
      setStopScannerCallback: this.setStopScannerCallback.bind(this)
    };

    return this.scanner = embedded_.scan(scanOptions).catch(this.permissionDenied.bind(this));
  },

  beforeScannerStart() {
    this.ui.shadowAreaBox.removeClass('hidden');

    this.showStatusMessage({
      type: 'tip',
      message: _.I18n("make the book's barcode fit in the box"),
      // displayDelay: 1000
      displayTime: 29 * 1000
    });

    return this.showStatusMessage({
      message: _.I18n('failing_scan_tip'),
      type: 'support',
      displayDelay: 30 * 1000,
      // Display only if no ISBN, valid or not, was detected
      displayCondition: () => (this.batch.length === 0) && !this.invalidIsbnDetected,
      displayTime: 30 * 1000
    });
  },

  addIsbn(isbn){
    this._lastIsbn = isbn;

    if (this.batch.includes(isbn)) { return this.showDuplicateIsbnWarning(isbn); }

    this.batch.push(isbn);
    this.precachingEntityData(isbn);

    this._lastSuccessTime = Date.now();
    this.showStatusMessage({
      message: _.i18n('added:') + ' ' + isbn,
      type: 'success',
      displayTime: 4000
    });

    this.updateCounter();

    if (this.batch.length === 1) {
      this.ui.validate.removeClass('hidden');
      // The shadow barcode shouldn't be needed anymore
      this.ui.shadowAreaBox.addClass('hidden');
      return this.initMultiBarcodeTip();
    }
  },

  precachingEntityData(isbn){
    // Pre-requesting the entity's data to let the time to the server
    // to possibly fetch dataseeds, while we will only need the data later.
    // If successful, the entities will be pre-cached
    return app.request('get:entity:model', `isbn:${isbn}`)
    .catch(err=> {
      if (err.message.match('entity_not_found')) { return this.updateNotFoundCounter(isbn);
      } else { throw err; }
  }).catch(_.Error('isbn batch pre-cache err'));
  },

  updateNotFoundCounter(isbn){
    this.notFound.push(isbn);
    const notFoundCount = this.notFound.length;
    if (notFoundCount === 1) { this.ui.notFoundCounter.parent().removeClass('hidden'); }
    return this.ui.notFoundCounter.text(notFoundCount);
  },

  showDuplicateIsbnWarning(isbn){
    const now = Date.now();
    if (this._lastSuccessTime == null) { this._lastSuccessTime = 0; }
    if (this._lastDuplicate == null) { this._lastDuplicate = 0; }

    const differentIsbn = isbn !== this._lastIsbn;
    // Do not show to soon after the successful scan
    // and debounce duplicate messages
    const debounced = ((now - this._lastSuccessTime) > 5000) && ((now - this._lastDuplicate) > 3000);

    if (differentIsbn || debounced) {
      this._lastDuplicate = Date.now();
      return this.showStatusMessage({
        message: _.I18n('this ISBN was already scanned'),
        type: 'warning',
        displayTime: 2000
      });
    }
  },

  initMultiBarcodeTip() {
    return this.showStatusMessage({
      message: _.I18n('multi_barcode_scan_tip'),
      type: 'tip',
      // Show the tip once the success message is over
      displayDelay: 2000,
      // Do not display if already several ISBNs were scanned
      displayCondition: () => this.batch.length === 1,
      displayTime: 5000
    });
  },

  showStatusMessage(params){
    const { message, type, displayDelay, displayCondition, displayTime } = params;

    const showMessage = () => {
      if (this.isDestroyed) { return; }
      if ((displayCondition != null) && !displayCondition()) { return; }

      this.ui.statusMessage.html(_.icon(iconPerType[type]) + message)
      .addClass('shown')
      // Used as a CSS selector
      .attr('data-type', type);

      this._lastMessage = message;

      const hideMessage = () => {
        if (this.isDestroyed || (this._lastMessage !== message)) { return; }
        return this.ui.statusMessage.removeClass('shown');
      };

      return this.setTimeout(hideMessage, displayTime);
    };

    if (displayDelay != null) { return this.setTimeout(showMessage, displayDelay);
    } else { return showMessage(); }
  },

  showInvalidIsbnWarning(invalidIsbn){
    return this.showStatusMessage({
      message: _.i18n('invalid ISBN') + ': ' + invalidIsbn,
      type: 'warning',
      displayTime: 5000
    });
  },

  updateCounter(count){
    // Prevent crashing with a 'TypeError: this.ui.totalCounter.text is not a function' error
    if (this.isDestroyed) { return; }
    this.ui.totalCounter.text(`(${this.batch.length})`);
    this.ui.validate.addClass('flash');
    return this.setTimeout(this.ui.validate.removeClass.bind(this.ui.validate, 'flash'), 1000);
  },

  permissionDenied(err){
    if (err.reason === 'permission_denied') {
      _.log('permission denied: closing scanner');
    } else {
      _.error(err, 'scan error');
    }

    // In any case, close
    return this.close();
  },

  validate() { return app.execute('show:add:layout:import:isbns', this.batch); },

  close() {
    // come back to the previous view
    // which should trigger @destroy as the previous view is expected to be shown
    // in app.layout.main too
    return window.history.back();
  },

  setStopScannerCallback(fn){ return this.stopScanner = fn; },

  onDestroy() { return this.stopScanner?.(); }
});

var iconPerType = {
  success: 'check',
  support: 'support',
  tip: 'info-circle',
  warning: 'warning'
};
