/* eslint-disable
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default {
  // For more complete data (author, license, ...)
  // see in the server repo: server/data/commons/thumb.coffee
  thumbnail (file, width = '100') {
    if (file == null) { return }
    if (!alreadyEncoded(file)) { file = _.fixedEncodeURIComponent(file) }
    // Example:
    // - 2000px-Gallimard,_rue_Gallimard.jpg => Gallimard,_rue_Gallimard.jpg
    file = file.replace(/^\d+px-/, '')
    return `https://commons.wikimedia.org/wiki/Special:FilePath/${file}?width=${width}`
  }
}

var alreadyEncoded = file => file.match(/%[0-9A-F]/) != null
