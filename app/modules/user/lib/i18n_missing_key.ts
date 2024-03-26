import { debounce } from 'underscore'
import app from '#app/app'
import log_ from '#lib/loggers'
import preq from '#lib/preq'

let missingKeys = []
let disabled = false

export default function (key) {
  if (disabled) return
  if ((key != null) && !missingKeys.includes(key)) {
    missingKeys.push(key)
    return lazyMissingKey()
  }
}

const sendMissingKeys = function () {
  if (missingKeys.length > 0) {
    const keysToSend = missingKeys
    // Keys added after this point will join the next batch
    missingKeys = []
    return preq.post(app.API.i18n, { missingKeys: keysToSend })
    .then(() => log_.info(keysToSend, 'i18n:missing added'))
    .catch(err => {
      if (err.statusCode !== 404) throw err
      log_.warn('i18n missing key service is disabled')
      disabled = true
    })
    .catch(log_.Error('i18n:missing keys failed to be added'))
  }
}

const lazyMissingKey = debounce(sendMissingKeys, 500)
