drawCanvas = require './draw_canvas'
isbn_ = require 'lib/isbn'
screen_ = require 'lib/screen'
onDetected = require './on_detected'

{ prepare:prepareQuagga, get:getQuagga } = require('lib/get_assets')('quagga')
{ prepare:prepareIsbn2, get:getIsbn2 } = require('lib/get_assets')('isbn2')

module.exports =
  # pre-fetch assets when the scanner is probably about to be used
  # to be ready to start scanning faster
  prepare: -> Promise.all [ prepareQuagga(), prepareIsbn2() ]
  scan: (params)->
    Promise.all [ getQuagga(), getIsbn2() ]
    .then startScanning.bind(null, params)
    .catch _.ErrorRethrow('embedded scanner err')

startScanning = (params)->
  { beforeScannerStart, onDetectedActions, setStopScannerCallback } = params
  # Using a promise to get a friendly way to pass errors
  # but this promise will never resolve, and will be terminated,
  # if everything goes well, by a cancel event
  return new Promise (resolve, reject)->
    constraints = getConstraints()
    _.log 'starting quagga initialization'

    cancelled = false
    stopScanner = ->
      _.log 'stopping quagga'
      cancelled = true
      Quagga.stop()

    setStopScannerCallback stopScanner

    Quagga.init getOptions(constraints), (err)->
      if cancelled then return
      if err
        err.reason = 'permission_denied'
        return reject err

      beforeScannerStart?()
      _.log 'quagga initialization finished. Starting'
      Quagga.start()

      Quagga.onProcessed drawCanvas()

      Quagga.onDetected onDetected(onDetectedActions)

# see doc: https://github.com/serratus/quaggaJS#configuration
getOptions = (constraints)->
  baseOptions.inputStream.target = document.querySelector '.embedded .container'
  baseOptions.inputStream.constraints = constraints
  return baseOptions

getConstraints = ->
  minDimension = _.min [ screen_.width(), screen_.height() ]
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
