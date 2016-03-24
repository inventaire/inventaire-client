# keep in sync with app/modules/inventory/views/add/templates/scan.hbs
selector = '#embedded'
drawCanvas = require './draw_canvas'

module.exports = ->
  new Promise (resolve, reject)->
    constraints = getConstraints()
    $target = $(selector)
    _.log 'starting quagga initialization'
    Quagga.init getOptions(constraints), (err) ->
      if err
        _.error err, 'quagga init err'
        return reject err

      _.log 'quagga initialization finished. Starting'
      Quagga.start()
      $target.show()

      Quagga.onDetected (result)->
        # TODO: verify that we get a valid ISBN before stopping and resolving
        Quagga.stop()
        $target.hide()
        _.log result, 'result'
        resolve result.codeResult.code

      Quagga.onProcessed drawCanvas(constraints)


# see doc: https://github.com/serratus/quaggaJS#configuration
getOptions = (constraints)->
  baseOptions.inputStream.target = document.querySelector selector
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
  # drawBoundingBox: false
  # showFrequency: false
  # drawScanline: true
  # showPattern: false
