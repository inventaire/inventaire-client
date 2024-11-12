import { min } from 'underscore'
import assert_ from '#app/lib/assert_types'
import log_ from '#app/lib/loggers'
import { getViewportHeight, getViewportWidth } from '#app/lib/screen'
import { drawCanvasFactory } from './draw_canvas.ts'
import { onDetectedFactory, type OnDetectedActions } from './on_detected.ts'
import type { QuaggaJSCodeReader } from '@ericblade/quagga2'

interface ScannerParams {
  containerElement: HTMLElement
  beforeScannerStart: () => void
  onDetectedActions: OnDetectedActions
  setStopScannerCallback: (fn: () => void) => void
}

export async function startQuaggaScanner (params: ScannerParams) {
  // For some unknown reason, importing Quagga statically makes scanning fail:
  //   message: 't is undefined',
  //   stack: o.createLiveStream@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:44717
  //     i@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:24184
  //     init@webpack-internal:///./node_modules/quagga/dist/quagga.min.js:1:29451
  //     startScanning/<@webpack-internal:///./app/modules/inventory/lib/scanner/embedded.js:46:41
  // But importing it dynamically works
  const { default: Quagga } = await import('@ericblade/quagga2')

  const { containerElement, beforeScannerStart, onDetectedActions, setStopScannerCallback } = params
  assert_.object(containerElement)
  // Using a promise to get a friendly way to pass errors
  // but this promise will never resolve, and will be terminated,
  // if everything goes well, by a cancel event
  return new Promise((resolve, reject) => {
    log_.info('starting quagga initialization')

    let cancelled = false
    const stopScanner = function () {
      log_.info('stopping quagga')
      cancelled = true
      return Quagga.stop()
    }

    setStopScannerCallback(stopScanner)

    const config = getConfig(containerElement)

    Quagga.init(config, err => {
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

const verticalMargin = '30%'
const horizontalMargin = '15%'

// See doc: https://github.com/ericblade/quagga2#quaggainitconfig-callback
function getConfig (containerElement: HTMLElement) {
  return {
    inputStream: {
      name: 'Live',
      area: {
        top: verticalMargin,
        right: horizontalMargin,
        left: horizontalMargin,
        bottom: verticalMargin,
      },
      target: containerElement,
      constraints: getConstraints(),
    },
    // From the docs https://github.com/ericblade/quagga2#locate:
    // "Why would someone turn this feature off? Localizing a barcode is a computationally expensive operation and might not work properly on some devices.
    // Another reason would be the lack of auto-focus producing blurry images which makes the localization feature very unstable.
    // However, even if none of the above apply, there is one more case where it might be useful to disable locate: If the orientation, and/or the approximate position of the barcode is known,
    // or if you want to guide the user through a rectangular outline. This can increase performance and robustness at the same time."
    locate: false,
    frequency: 5,
    decoder: {
      readers: [ 'ean_reader' ] as QuaggaJSCodeReader[],
      multiple: false,
    },
  }
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
