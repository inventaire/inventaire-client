drawCanvas = require './draw_canvas'
isbn_ = require 'lib/isbn'

{ prepare, get:getQuagga } = require('lib/get_assets')('quagga')

module.exports =
  # pre-fetch quagga when the scanner is probably about to be used
  # to be ready to start scanning faster
  prepare: prepare
  scan: (beforeStart)->
    beforeStart or= _.noop

    getQuagga()
    .then startScanning.bind(null, beforeStart)
    .then _.Log('embedded scanner isbn')
    .then (isbn)-> app.execute 'show:entity:add', "isbn:#{isbn}"
    .catch _.ErrorRethrow('embedded scanner err')

startScanning = (beforeStart)->
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
        # TODO: verify that this is a standard message
        if err.message is 'The operation is insecure.'
          err.reason = 'permission_denied'

        return reject err

      beforeStart()
      _.log 'quagga initialization finished. Starting'
      Quagga.start()

      Quagga.onProcessed drawCanvas()

      Quagga.onDetected (result)->
        _.log result, 'result'
        candidate = result.codeResult.code
        if isbn_.isIsbn candidate
          Quagga.stop()
          resolve result.codeResult.code
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

