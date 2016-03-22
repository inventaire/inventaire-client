# keep in sync with app/modules/inventory/views/add/templates/scan.hbs
selector = '#embedded'
drawCanvas = require './draw_canvas'

module.exports = ->
  new Promise (resolve, reject)->
    $target = $(selector)
    _.log 'starting quagga initialization'
    Quagga.init getOptions(), (err) ->
      if err
        _.error err, 'quagga init err'
        return reject err

      _.log 'quagga initialization finished. Starting'
      Quagga.start()
      $target.show()

      Quagga.onDetected (result)->
        Quagga.stop()
        $target.hide()
        _.log result, 'result'
        resolve result.codeResult.code
        $('#result').html(result.codeResult.code)

      Quagga.onProcessed drawCanvas


# see doc: https://github.com/serratus/quaggaJS#configuration
getOptions = ->
  baseOptions.inputStream.target = document.querySelector selector
  return baseOptions

verticalMargin = '40%'
horizontalMargin = '15%'
baseOptions =
  inputStream:
    name: 'Live'
    type: 'LiveStream'
    constraints:
      width: 640
      height: 480
      # facing: 'environment'
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
