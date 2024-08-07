import { min } from 'underscore'
import assert_ from '#app/lib/assert_types'
import log_ from '#app/lib/loggers'
import { getViewportHeight, getViewportWidth } from '#app/lib/screen'
import { drawCanvasFactory } from './draw_canvas.ts'
import { onDetectedFactory, type OnDetectedActions } from './on_detected.ts'

interface ScannerParams {
  containerElement: HTMLElement
  beforeScannerStart: () => void
  onDetectedActions: OnDetectedActions
  setStopScannerCallback: (fn: () => void) => void
}

export async function startEmbeddedScanner (params: ScannerParams) {
  // For some unknown reason, importing Quagga statically makes scanning fail:
  //   message: 't is undefined',
  //   stack: o.createLiveStream@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:44717
  //     i@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:24184
  //     init@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:29451
  //     startScanning/<@webpack-internal:///./app/modules/inventory/lib/scanner/embedded.js:46:41
  // But importing it dynamically works
  const { default: Quagga } = await import('quagga')

  const { containerElement, beforeScannerStart, onDetectedActions, setStopScannerCallback } = params
  assert_.object(containerElement)
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

    Quagga.init(getOptions(containerElement, constraints), err => {
      if (cancelled) return
      if (err) {
        err.reason = 'permission_denied'
        return reject(err)
      }

      beforeScannerStart?.()
      log_.info('quagga initialization finished. Starting')
      Quagga.start()

      Quagga.onProcessed(drawCanvasFactory(Quagga))

      Quagga.onDetected(onDetectedFactory(onDetectedActions))
    })
  })
}

// See doc: https://github.com/serratus/quaggaJS#configuration
function getOptions (containerElement: HTMLElement, constraints: MediaTrackConstraints) {
  // @ts-expect-error
  baseOptions.inputStream.target = containerElement
  // @ts-expect-error
  baseOptions.inputStream.constraints = constraints
  return baseOptions
}

// See https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackConstraints/facingMode
const facingMode = { ideal: 'environment' }

function getConstraints () {
  const minDimension = min([ getViewportWidth(), getViewportHeight() ])
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
      bottom: verticalMargin,
    },
  },
  // disabling locate as I couldn't make it work:
  // the user is thus expected to be aligned with the barcode
  locate: false,
  // locate: true
  decoder: {
    readers: [ 'ean_reader' ],
    multiple: false,
  },
}
