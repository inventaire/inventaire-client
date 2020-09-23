labels = {}
previouslyMissing = {}

module.exports =
  getLabel: (uri)-> labels[uri]

  setLabel: (uri, label)-> labels[uri] = label

  getKnownUris: -> Object.keys labels

  resetLabels: -> labels = {}

  invalidateLabel: (uri)->
    delete labels[uri]
    delete previouslyMissing[uri]

  addPreviouslyMissingUris: (uris)->
    for uri in uris
      previouslyMissing[uri] = true
    return

  wasntPrevisoulyMissing: (uri)-> not previouslyMissing[uri]
