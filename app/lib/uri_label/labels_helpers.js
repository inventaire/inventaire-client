/* eslint-disable
    no-return-assign,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let labels = {}
const previouslyMissing = {}

export default {
  getLabel (uri) { return labels[uri] },

  setLabel (uri, label) { return labels[uri] = label },

  getKnownUris () { return Object.keys(labels) },

  resetLabels () { return labels = {} },

  invalidateLabel (uri) {
    delete labels[uri]
    return delete previouslyMissing[uri]
  },

  addPreviouslyMissingUris (uris) {
    for (const uri of uris) {
      previouslyMissing[uri] = true
    }
  },

  wasntPrevisoulyMissing (uri) { return !previouslyMissing[uri] }
}
