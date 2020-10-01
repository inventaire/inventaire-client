let labels = {}
const previouslyMissing = {}

export default {
  getLabel (uri) { return labels[uri] },

  setLabel (uri, label) { labels[uri] = label },

  getKnownUris () { return Object.keys(labels) },

  resetLabels () { labels = {} },

  invalidateLabel (uri) {
    delete labels[uri]
    delete previouslyMissing[uri]
  },

  addPreviouslyMissingUris (uris) {
    for (const uri of uris) {
      previouslyMissing[uri] = true
    }
  },

  wasntPrevisoulyMissing (uri) { return !previouslyMissing[uri] }
}
