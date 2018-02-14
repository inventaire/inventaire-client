drawCanvas = require './draw_canvas'
isbn_ = require 'lib/isbn'

{ prepare, get:getQuaggaIsbnBundle } = require('lib/get_assets')('quaggaIsbn')

module.exports =
  # pre-fetch quagga when the scanner is probably about to be used
  # to be ready to start scanning faster
  prepare: prepare
  scan: (params)->
    { beforeScannerStart, addIsbn } = params
    beforeScannerStart or= _.noop

    getQuaggaIsbnBundle()
    .then startScanning.bind(null, beforeScannerStart, addIsbn)
    .catch _.ErrorRethrow('embedded scanner err')

startScanning = (beforeScannerStart, addIsbn)->
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

      Quagga.onDetected (result)->
        # TODO: ignore scans happening less than 200ms after a known valid case
        # to increase chances of rejecting invalid scans that occure
        # once in a while
        candidate = result.codeResult.code
        # window.ISBN is the isbn2 module, fetched by getQuaggaIsbnBundle
        # If the candidate code can't be parsed, it's not a valid ISBN
        if window.ISBN.parse(candidate)?
          addIsbn result.codeResult.code
        else
          _.log candidate, 'discarded result. continuing to try'

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
