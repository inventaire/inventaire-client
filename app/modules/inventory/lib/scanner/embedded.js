import drawCanvas from './draw_canvas'
import screen_ from 'lib/screen'
import onDetected from './on_detected'

const { prepare: prepareQuagga, get: getQuagga } = require('lib/get_assets')('quagga')
const { prepare: prepareIsbn2, get: getIsbn2 } = require('lib/get_assets')('isbn2')

export default {
  // pre-fetch assets when the scanner is probably about to be used
  // to be ready to start scanning faster
  prepare () { return Promise.all([ prepareQuagga(), prepareIsbn2() ]) },
  scan (params) {
    return Promise.all([ getQuagga(), getIsbn2() ])
    .then(startScanning.bind(null, params))
    .catch(_.ErrorRethrow('embedded scanner err'))
  }
}

const startScanning = function (params) {
  const { beforeScannerStart, onDetectedActions, setStopScannerCallback } = params
  // Using a promise to get a friendly way to pass errors
  // but this promise will never resolve, and will be terminated,
  // if everything goes well, by a cancel event
  return new Promise((resolve, reject) => {
    const constraints = getConstraints()
    _.log('starting quagga initialization')

    let cancelled = false
    const stopScanner = function () {
      _.log('stopping quagga')
      cancelled = true
      return Quagga.stop()
    }

    setStopScannerCallback(stopScanner)

    return Quagga.init(getOptions(constraints), err => {
      if (cancelled) return
      if (err) {
        err.reason = 'permission_denied'
        return reject(err)
      }

      beforeScannerStart?.()
      _.log('quagga initialization finished. Starting')
      Quagga.start()

      Quagga.onProcessed(drawCanvas())

      return Quagga.onDetected(onDetected(onDetectedActions))
    })
  })
}

// see doc: https://github.com/serratus/quaggaJS#configuration
const getOptions = function (constraints) {
  baseOptions.inputStream.target = document.querySelector('.embedded .container')
  baseOptions.inputStream.constraints = constraints
  return baseOptions
}

const getConstraints = function () {
  const minDimension = _.min([ screen_.width(), screen_.height() ])
  if (minDimension > 720) {
    return { width: 1280, height: 720 }
  } else { return { width: 640, height: 480 } }
}

const verticalMargin = '30%'
const horizontalMargin = '15%'

const baseOptions = {
  inputStream: {
    name: 'Live',
    type: 'LiveStream',
    area: {
      top: verticalMargin,
      right: horizontalMargin,
      left: horizontalMargin,
      bottom: verticalMargin
    }
  },
  // disabling locate as I couldn't make it work:
  // the user is thus expected to be aligned with the barcode
  locate: false,
  // locate: true
  decoder: {
    readers: [ 'ean_reader' ],
    multiple: false
  }
}
