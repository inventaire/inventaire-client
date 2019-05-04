embedded_ = require 'modules/inventory/lib/scanner/embedded'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/embedded_scanner'
  className: 'embedded'
  behaviors:
    Loading: {}

  ui:
    statusMessage: '.statusMessage'
    shadowAreaBox: '#shadowAreaBox'
    validate: '#validateScan'
    totalCounter: '#totalCounter'
    notFoundCounter: '#notFoundCounter'
    failing: '.failing'

  events:
    'click #closeScan': 'close'
    'click #validateScan': 'validate'

  onShow: ->
    app.execute 'last:add:mode:set', 'scan:embedded'
    # Removing the timeout on the loader as it depend on the time
    # the user takes to give the permission to access the camera
    behaviorsPlugin.startLoading.call @, { timeout: 'none' }

    @batch = []
    @notFound = []

    scanOptions =
      beforeScannerStart: @beforeScannerStart.bind @
      onDetectedActions:
        addIsbn: @addIsbn.bind @
        showInvalidIsbnWarning: @showInvalidIsbnWarning.bind @
      setStopScannerCallback: @setStopScannerCallback.bind @

    @scanner = embedded_.scan(scanOptions).catch @permissionDenied.bind(@)

  beforeScannerStart: ->
    @ui.shadowAreaBox.removeClass 'hidden'

    @showStatusMessage
      type: 'tip'
      message: _.I18n "make the book's barcode fit in the box"
      # displayDelay: 1000
      displayTime: 29 * 1000

    @showStatusMessage
      message: _.I18n 'failing_scan_tip'
      type: 'support'
      displayDelay: 30 * 1000
      # Display only if no ISBN, valid or not, was detected
      displayCondition: => @batch.length is 0 and not @invalidIsbnDetected
      displayTime: 30 * 1000

  addIsbn: (isbn)->
    @_lastIsbn = isbn

    if isbn in @batch then return @showDuplicateIsbnWarning isbn

    @batch.push isbn
    @precachingEntityData isbn

    @_lastSuccessTime = Date.now()
    @showStatusMessage
      message: _.i18n('added:') + ' ' + isbn
      type: 'success'
      displayTime: 4000

    @updateCounter()

    if @batch.length is 1
      @ui.validate.removeClass 'hidden'
      # The shadow barcode shouldn't be needed anymore
      @ui.shadowAreaBox.addClass 'hidden'
      @initMultiBarcodeTip()

  precachingEntityData: (isbn)->
    # Pre-requesting the entity's data to let the time to the server
    # to possibly fetch dataseeds, while we will only need the data later.
    # If successful, the entities will be pre-cached
    app.request 'get:entity:model', "isbn:#{isbn}"
    .catch (err)=>
      if err.message.match('entity_not_found') then @updateNotFoundCounter isbn
      else throw err
    .catch _.Error('isbn batch pre-cache err')

  updateNotFoundCounter: (isbn)->
    @notFound.push isbn
    notFoundCount = @notFound.length
    if notFoundCount is 1 then @ui.notFoundCounter.parent().removeClass 'hidden'
    @ui.notFoundCounter.text notFoundCount

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

  initMultiBarcodeTip: ->
    @showStatusMessage
      message: _.I18n 'multi_barcode_scan_tip'
      type: 'tip'
      # Show the tip once the success message is over
      displayDelay: 2000
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

      @setTimeout hideMessage, displayTime

    if displayDelay? then @setTimeout showMessage, displayDelay
    else showMessage()

  showInvalidIsbnWarning: (invalidIsbn)->
    @showStatusMessage
      message: _.i18n('invalid ISBN') + ': ' + invalidIsbn
      type: 'warning'
      displayTime: 5000

  updateCounter: (count)->
    @ui.totalCounter.text "(#{@batch.length})"
    @ui.validate.addClass 'flash'
    @setTimeout @ui.validate.removeClass.bind(@ui.validate, 'flash'), 1000

  permissionDenied: (err)->
    if err.reason is 'permission_denied'
      _.log 'permission denied: closing scanner'
    else
      _.error err, 'scan error'

    # In any case, close
    @close()

  validate: -> app.execute 'show:add:layout:import:isbns', @batch

  close: ->
    # come back to the previous view
    # which should trigger @destroy as the previous view is expected to be shown
    # in app.layout.main too
    window.history.back()

  setStopScannerCallback: (fn)-> @stopScanner = fn

  onDestroy: -> @stopScanner?()

iconPerType =
  success: 'check'
  support: 'support'
  tip: 'info-circle'
  warning: 'warning'
