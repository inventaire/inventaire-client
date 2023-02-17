import log_ from '#lib/loggers'
import drawCanvas from './draw_canvas.js'
import { getViewportHeight, getViewportWidth } from '#lib/screen'
import onDetected from './on_detected.js'

export default {
  async scan (params) {
    startScanning(params)
    .catch(log_.ErrorRethrow('embedded scanner err'))
  }
}

const startScanning = async function (params) {
  // For some unknown reason, importing Quagga statically makes scanning fail:
  //   message: 't is undefined',
  //   stack: o.createLiveStream@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:44717
  //     i@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:24184
  //     init@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:29451
  //     startScanning/<@webpack-internal:///./app/modules/inventory/lib/scanner/embedded.js:46:41
  // But importing it dynamically works
  const { default: Quagga } = await import('quagga')

  const { beforeScannerStart, onDetectedActions, setStopScannerCallback } = params
  // Using a promise to get a friendly way to pass errors
  // but this promise will never resolve, and will be terminated,
  // if everything goes well, by a cancel event
  return new Promise((resolve, reject) => {
    const constraints = getConstraints()
    log_.info('starting quagga initialization')

    let cancelled = false
    const stopScanner = function () {
      log_.info('stopping quagga')
      cancelled = true
      return Quagga.stop()
    }

    setStopScannerCallback(stopScanner)

    Quagga.init(getOptions(constraints), err => {
      if (cancelled) return
      if (err) {
        err.reason = 'permission_denied'
        return reject(err)
      }

      beforeScannerStart?.()
      log_.info('quagga initialization finished. Starting')
      Quagga.start()

      Quagga.onProcessed(drawCanvas(Quagga))

      Quagga.onDetected(onDetected(onDetectedActions))
    })
  })
}

// See doc: https://github.com/serratus/quaggaJS#configuration
const getOptions = function (constraints) {
  baseOptions.inputStream.target = document.querySelector('.embedded .container')
  baseOptions.inputStream.constraints = constraints
  return baseOptions
}

// See https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackConstraints/facingMode
const facingMode = { ideal: 'environment' }

const getConstraints = function () {
  const minDimension = _.min([ getViewportWidth(), getViewportHeight() ])
  if (minDimension > 720) {
    return { width: 1280, height: 720, facingMode }
  } else {
    return { width: 640, height: 480, facingMode }
  }
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
