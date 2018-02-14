embedded_ = require 'modules/inventory/lib/scanner/embedded'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/embedded_scanner'
  className: 'embedded'
  behaviors:
    Loading: {}

  ui:
    statusMessage: '.statusMessage'
    validate: '#validateScan'
    counter: '.counter'
    failing: '.failing'

  events:
    'click #closeScan': 'close'
    'click #validateScan': 'validate'

  onShow: ->
    app.execute 'last:add:mode:set', 'scan:embedded'
    # removing the timeout on the loader as it depend on the time the user takes
    # to give the permission to access the camera
    behaviorsPlugin.startLoading.call @, { timeout: 'none' }

    # TODO: display a tip on how to position the scanner on the barcode

    # Only start the timeout before showing the failing scan tip once the scanner
    # started and not when it might still be waiting for Quagga download
    beforeScannerStart = @initFailingScanTip.bind @

    @batch = []

    @scanner = embedded_.scan { beforeScannerStart, addIsbn: @addIsbn.bind(@) }
      .catch @permissionDenied.bind(@)

  addIsbn: (isbn)->
    @_lastIsbn = isbn

    if isbn in @batch then return @showDuplicateIsbnWarning isbn

    @batch.push isbn
    @precachingEntityData isbn

    @_lastSuccessTime = Date.now()
    @showStatusMessage
      message: _.i18n('added:') + ' ' + isbn
      type: 'success'
      displayTime: 2000

    # Synchronize with the status message
    # setTimeout @updateCounter.bind(@), 300
    @updateCounter()

    if @batch.length is 1
      @ui.validate.removeClass 'hidden'
      @initMultiBarcodeTip()

  precachingEntityData: (isbn)->
    # Pre-requesting the entity's data to let the time to the server
    # to possibly fetch dataseeds, while we will only need the data later.
    # If successful, the entities will be pre-cached
    app.request 'get:entity:model', "isbn:#{isbn}"
    .catch _.Error('isbn batch pre-cache err')

  showDuplicateIsbnWarning: (isbn)->
    now = Date.now()
    @_lastSuccessTime ?= 0
    @_lastDuplicate ?= 0

    differentIsbn = isbn isnt @_lastIsbn
    # Do not show to soon after the successful scan
    # and debounce duplicate messages
    debounced = now - @_lastSuccessTime > 5000 and now - @_lastDuplicate > 3000

    if differentIsbn or debounced
      @_lastDuplicate = Date.now()
      @showStatusMessage
        message: _.I18n 'this ISBN was already scanned'
        type: 'warning'
        displayTime: 2000

  initFailingScanTip: ->
    @showStatusMessage
      message: _.I18n 'failing_scan_tip'
      type: 'support'
      displayDelay: 30*1000
      displayCondition: => @batch.length is 0
      displayTime: 30*1000

  initMultiBarcodeTip: ->
    @showStatusMessage
      message: _.I18n 'multi_barcode_scan_tip'
      type: 'tip'
      # Show the tip once the success message is over
      displayDelay: 3000
      # Do not display if already several ISBNs were scanned
      displayCondition: => @batch.length is 1
      displayTime: 5000

  showStatusMessage: (params)->
    { message, type, displayDelay, displayCondition, displayTime } = params

    showMessage = =>
      if @isDestroyed then return
      if displayCondition? and not displayCondition() then return

      @ui.statusMessage.html _.icon(iconPerType[type]) + message
      .addClass 'shown'
      # Used as a CSS selector
      .attr 'data-type', type

      @_lastMessage = message

      hideMessage = =>
        if @isDestroyed or @_lastMessage isnt message then return
        @ui.statusMessage.removeClass 'shown'

      setTimeout hideMessage, displayTime

    if displayDelay? then setTimeout showMessage, displayDelay
    else showMessage()

  updateCounter: (count)->
    @ui.counter.text "(#{@batch.length})"
    @ui.validate.addClass 'flash'
    setTimeout @ui.validate.removeClass.bind(@ui.validate, 'flash'), 1000

  permissionDenied: (err)->
    if err.reason is 'permission_denied'
      _.log 'permission denied: closing scanner'

    # In any case, close
    @close()

  # TODO: Pass to the ISBN importer
  validate: -> alert @batch

  close: ->
    # come back to the previous view
    # which should trigger @destroy as the previous view is expected to be shown
    # in app.layout.main too
    window.history.back()

  onDestroy: ->
    # Cancelling the promise to let the opportunity to Quagga to stop properly
    # and avoid having a promise unfulfilled.
    # Has no effect if the promise is already fulfilled
    @scanner.cancel()

iconPerType =
  success: 'check'
  support: 'support'
  tip: 'info-circle'
  warning: 'warning'
