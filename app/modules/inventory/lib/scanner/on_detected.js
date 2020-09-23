module.exports = (onDetectedActions)->
  { showInvalidIsbnWarning, addIsbn } = onDetectedActions
  lastIsbnScanTime = 0
  lastIsbnScanned = null
  lastIsbnAdded = null

  lastInvalidIsbn = null
  identicalValidIsbnCount = 0
  identicalInvalidIsbnCount = 0

  return (result)->
    candidate = result.codeResult.code
    # window.ISBN is the object created by the isbn2 module
    # If the candidate code can't be parsed, it's not a valid ISBN
    if window.ISBN.parse(candidate)?
      identicalInvalidIsbnCount = 0
    else
      if candidate is lastInvalidIsbn
        identicalInvalidIsbnCount++
      else
        lastInvalidIsbn = candidate
        identicalInvalidIsbnCount = 0
      # Waiting for 3 successive scans before showing a warning
      # to be sure it's not just an error from the scanner
      # Known case: some books have an ISBN but the barcode EAN
      # isn't based on it
      if identicalInvalidIsbnCount is 3
        showInvalidIsbnWarning candidate
        # Reset count to show the same warning in 3 scans again
        identicalInvalidIsbnCount = 0

      return _.log candidate, 'discarded result: invalid ISBN'

    now = Date.now()
    timeSinceLastIsbnScan = now - lastIsbnScanTime
    lastIsbnScanTime = now

    if candidate is lastIsbnAdded then return

    # Too close in time since last valid result to be true:
    # (scanning 2 different barcodes in less than 2 seconds is a performance)
    # it's probably a scan error, which happens from time to time,
    # especially with bad light
    if timeSinceLastIsbnScan < 200
      return _.log candidate, 'discarded result: too close in time'

    # Wait for scanning the same ISBN 2 times in a row to consider it the valid one
    # Addressing https://github.com/inventaire/inventaire-client/issues/183#issuecomment-536176154
    if candidate is lastIsbnScanned
      lastIsbnAdded = candidate
      addIsbn candidate
    else
      lastIsbnScanned = candidate
