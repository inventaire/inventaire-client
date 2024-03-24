let labels = {}
const previouslyMissing = {}

export const getLabel = uri => labels[uri]

export const setLabel = (uri, label) => {
  labels[uri] = label
}

export const getKnownUris = () => Object.keys(labels)

export const resetLabels = () => { labels = {} }

export const invalidateLabel = uri => {
  delete labels[uri]
  delete previouslyMissing[uri]
}

export const addPreviouslyMissingUris = uris => {
  for (const uri of uris) {
    previouslyMissing[uri] = true
  }
}

export const wasntPrevisoulyMissing = uri => !previouslyMissing[uri]
