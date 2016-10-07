labels = {}
{ formatLabel } = require 'lib/wikimedia/wikidata'

module.exports =
  getLabel: (uri, lang)->
    data = labels[uri]
    if data?
      return data[lang] or data.en or data.original or _.pickOne(data)

  setLabel: (uri, lang, label)->
    label = formatLabel label
    labels[uri] or= {}
    labels[uri][lang] = label
    return label

  getKnownUris: -> Object.keys labels

  resetLabels: -> labels = {}
