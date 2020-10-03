import { i18n } from 'modules/user/lib/i18n'
import error_ from 'lib/error'
import importers from './importers'

export default function (source, data) {
  const { format, label, disableValidation } = importers[source]
  if (disableValidation) return

  if (!isValid[format](source, data)) {
    const message = i18n('data_mismatch', { source: label })
    // avoid attaching the whole file as context as it might be pretty heavy
    const err = error_.new(message, data.slice(0, 101))
    err.i18n = false
    throw err
  }
};

const isValid = {
  csv (source, data) {
    // Comparing the first 20 first characters
    // as those should be the header line and thus be constant
    const first20Char = data.slice(0, 20)
    return first20Char === importers[source].first20Characters
  },

  json (source, data) {
    if (data[0] !== '{') { return false }
    // No headers line here, so we look for the presence of a specific key instead
    const re = new RegExp(importers[source].specificKey)
    // Testing only an extract to avoid passing a super long doc to the regexp.
    // Make sure to choose a specificKey that would appear in this extract
    return re.test(data.slice(0, 1001))
  },

  all () { return true }
}
