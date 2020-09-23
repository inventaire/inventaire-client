/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const { action } = require('./endpoint')('images')

export default {
  upload (container, hash) { return action('upload', { container, hash }) },
  convertUrl: action('convert-url'),
  dataUrl (url) { return action('data-url', { url: encodeURIComponent(url) }) },
  gravatar: action('gravatar')
}
