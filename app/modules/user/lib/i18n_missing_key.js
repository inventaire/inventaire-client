/* eslint-disable
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let missingKeys = []
let disabled = false

export default function (key) {
  if (disabled) { return }
  if ((key != null) && !missingKeys.includes(key)) {
    missingKeys.push(key)
    return lazyMissingKey()
  }
};

const sendMissingKeys = function () {
  if (missingKeys.length > 0) {
    const keysToSend = missingKeys
    // Keys added after this point will join the next batch
    missingKeys = []
    return _.preq.post(app.API.i18n, { missingKeys: keysToSend })
    .then(res => _.log(keysToSend, 'i18n:missing added'))
    .catch(err => {
      if (err.statusCode !== 404) { throw err }
      _.warn('i18n missing key service is disabled')
      return disabled = true
    }).catch(_.Error('i18n:missing keys failed to be added'))
  }
}

var lazyMissingKey = _.debounce(sendMissingKeys, 500)
