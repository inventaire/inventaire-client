drawCanvas = require './draw_canvas'

module.exports = ->
  getQuagga()
  .then scan
  .then _.Log('embedded scanner isbn')
  .then (isbn)-> app.execute 'show:entity:add', "isbn:#{isbn}"
  .catch _.Error('embedded scanner err')

getQuagga = ->
  if window.Quagga?
    _.log 'Quagga already fetched'
    return _.preq.start
  else
    _.log 'fetching Quagga'
    return _.preq.getScript app.API.scripts.quagga()

scan = ->
  new Promise (resolve, reject, onCancel)->
    constraints = getConstraints()
    _.log 'starting quagga initialization'

    cancelled = false
    onCancel ->
      _.log 'cancelled promise: stopping quagga'
      cancelled = true
      Quagga.stop()

    Quagga.init getOptions(constraints), (err) ->
      if cancelled then return
      if err
        _.error err, 'quagga init err'
        return reject err

      _.log 'quagga initialization finished. Starting'
      Quagga.start()

      Quagga.onProcessed drawCanvas()

      Quagga.onDetected (result)->
        # TODO: verify that we get a valid ISBN before stopping and resolving
        Quagga.stop()
        _.log result, 'result'
        resolve result.codeResult.code

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

