embedded_ = require 'modules/inventory/lib/scanner/embedded'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/embedded_scanner'
  className: 'embedded'
  behaviors:
    Loading: {}

  ui:
    failing: '.failing'

  events:
    'click .close': 'close'
    'click .failing': 'hideFailingScanTip'

  onShow: ->
    app.execute 'last:add:mode:set', 'scan:embedded'
    # removing the timeout on the loader as it depend on the time the user takes
    # to give the permission to access the camera
    behaviorsPlugin.startLoading.call @, { timeout: 'none' }

    # Only start the timeout before showing the failing scan tip once the scanner
    # started and not when it might still be waiting for Quagga download
    beforeScannerStart = => setTimeout @showFailingScanTip.bind(@), 30*1000
    @scanner = embedded_.scan(beforeScannerStart).catch @permissionDenied.bind(@)

  showFailingScanTip: -> unless @isDestroyed then @ui.failing.fadeIn()
  hideFailingScanTip: -> @ui.failing.hide()

  permissionDenied: (err)->
    if err.reason is 'permission_denied'
      _.log 'permission denied: closing scanner'
      @close()
    # else: the error was already logged

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
