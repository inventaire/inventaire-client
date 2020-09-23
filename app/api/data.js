/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const { action } = require('./endpoint')('data')

export default {
  wikipediaExtract (lang, title) { return action('wp-extract', { lang, title }) },
  isbn (isbn) { return action('isbn', { isbn }) }
}
