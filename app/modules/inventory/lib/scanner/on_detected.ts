import ISBN from 'isbn3'
import log_ from '#lib/loggers'

export default function (onDetectedActions) {
  const { showInvalidIsbnWarning, addIsbn } = onDetectedActions
  let lastIsbnScanTime = 0
  let lastIsbnScanned = null
  let lastIsbnAdded = null

  let lastInvalidIsbn = null
  let identicalInvalidIsbnCount = 0

  return function (result) {
    const candidate = result.codeResult.code
    if (ISBN.parse(candidate) != null) {
      identicalInvalidIsbnCount = 0
    } else {
      if (candidate === lastInvalidIsbn) {
        identicalInvalidIsbnCount++
      } else {
        lastInvalidIsbn = candidate
        identicalInvalidIsbnCount = 0
      }
      // Waiting for 3 successive scans before showing a warning
      // to be sure it's not just an error from the scanner
      // Known case: some books have an ISBN but the barcode EAN
      // isn't based on it
      if (identicalInvalidIsbnCount === 3) {
        showInvalidIsbnWarning(candidate)
        // Reset count to show the same warning in 3 scans again
        identicalInvalidIsbnCount = 0
      }

      return log_.info(candidate, 'discarded result: invalid ISBN')
    }

    const now = Date.now()
    const timeSinceLastIsbnScan = now - lastIsbnScanTime
    lastIsbnScanTime = now

    if (candidate === lastIsbnAdded) return

    // Too close in time since last valid result to be true:
    // (scanning 2 different barcodes in less than 2 seconds is a performance)
    // it's probably a scan error, which happens from time to time,
    // especially with bad light
    if (timeSinceLastIsbnScan < 200) {
      return log_.info(candidate, 'discarded result: too close in time')
    }

    // Wait for scanning the same ISBN 2 times in a row to consider it the valid one
    // Addressing https://github.com/inventaire/inventaire-client/issues/183#issuecomment-536176154
    if (candidate === lastIsbnScanned) {
      lastIsbnAdded = candidate
      addIsbn(candidate)
    } else {
      lastIsbnScanned = candidate
    }
  }
}
