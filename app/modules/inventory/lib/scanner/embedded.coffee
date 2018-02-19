drawCanvas = require './draw_canvas'
isbn_ = require 'lib/isbn'

{ prepare, get:getQuaggaIsbnBundle } = require('lib/get_assets')('quaggaIsbn')

module.exports =
  # pre-fetch quagga when the scanner is probably about to be used
  # to be ready to start scanning faster
  prepare: prepare
  scan: (params)->
    { beforeScannerStart, actions } = params
    beforeScannerStart or= _.noop

    getQuaggaIsbnBundle()
    .then startScanning.bind(null, beforeScannerStart, actions)
    # Not catching the error to let the view handle where we should go next

startScanning = (beforeScannerStart, actions)->
  # Using a promise to get a friendly way to pass errors
  # but this promise will never resolve, and will be terminated,
  # if everything goes well, by a cancel event
  new Promise (resolve, reject, onCancel)->
    constraints = getConstraints()
    _.log 'starting quagga initialization'

    cancelled = false
    onCancel ->
      _.log 'cancelled promise: stopping quagga'
      cancelled = true
      Quagga.stop()

    Quagga.init getOptions(constraints), (err)->
      if cancelled then return
      if err
        err.reason = 'permission_denied'
        return reject err

      beforeScannerStart()
      _.log 'quagga initialization finished. Starting'
      Quagga.start()

      Quagga.onProcessed drawCanvas()

      Quagga.onDetected onDetected(actions)

# see doc: https://github.com/serratus/quaggaJS#configuration
getOptions = (constraints)->
  baseOptions.inputStream.target = document.querySelector '.embedded .container'
  baseOptions.inputStream.constraints = constraints
  return baseOptions

getConstraints = ->
  minDimension = _.min [ _.screenWidth(), _.screenHeight() ]
  if minDimension > 720 then { width: 1280, height: 720 }
  else { width: 640, height: 480 }

verticalMargin = '30%'
horizontalMargin = '15%'

baseOptions =
  inputStream:
    name: 'Live'
    type: 'LiveStream'
    area:
      top: verticalMargin
      right: horizontalMargin
      left: horizontalMargin
      bottom: verticalMargin
  # disabling locate as I couldn't make it work:
  # the user is thus expected to be aligned with the barcode
  locate: false
  # locate: true
  decoder:
    readers: [ 'ean_reader' ]
    multiple: false

onDetected = (actions)->
  lastIsbnScanTime = 0
  lastIsbn = null

  lastInvalidIsbn = null
  identicalInvalidIsbnCount = 0

  return (result)->
    candidate = result.codeResult.code
    # window.ISBN is the isbn2 module, fetched by getQuaggaIsbnBundle
    # If the candidate code can't be parsed, it's not a valid ISBN
    if window.ISBN.parse(candidate)?
      invalidIsbnCount = 0
    else
      if candidate is lastInvalidIsbn
        identicalInvalidIsbnCount++
      else
        lastInvalidIsbn = candidate
        identicalInvalidIsbnCount = 0
      # Waiting for 3 successive scans before showing a warning
      # to be sure it's not just an error from the scanner
      # Known case: some books have an ISBN but the barcode EAN
      # isn't based on it
      if identicalInvalidIsbnCount is 3
        actions.showInvalidIsbnWarning candidate
        # Reset count to show the same warning in 3 scans again
        identicalInvalidIsbnCount = 0

      return _.log candidate, 'discarded result: invalid ISBN'

    now = Date.now()
    timeSinceLastIsbnScan = now - lastIsbnScanTime
    lastIsbnScanTime = now

    if candidate is lastIsbn then return

    # Too close in time since last valid result to be true:
    # (scanning 2 different barcodes in less than 2 seconds is a performance)
    # it's probably a scan error, which happens from time to time,
    # especially with bad light
    if timeSinceLastIsbnScan < 500
      return _.log candidate, 'discarded result: too close in time'

    actions.addIsbn candidate
