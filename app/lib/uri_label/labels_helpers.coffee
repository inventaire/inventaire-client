labels = {}
previouslyMissing = {}

module.exports =
  getLabel: (uri, lang)->
    data = labels[uri]
    if data?
      return data[lang] or data.en or data.original or _.pickOne(data)

  setLabel: (uri, lang, label)->
    labels[uri] or= {}
    labels[uri][lang] = label
    return label

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
