labels = {}

module.exports =
  getLabel: (qid, lang)->
    data = labels[qid]
    if data?
      return data[lang] or data.en or data.original or _.pickOne(data)

  setLabel: (qid, lang, label)->
    label = formatLabel label
    labels[qid] or= {}
    labels[qid][lang] = label
    return label

  getKnownQids: -> Object.keys labels

  resetLabels: -> labels = {}


# It sometimes happen that a Wikidata label is a direct copy of the Wikipedia
# title, which can then have desambiguating parenthesis: we got to drop those
formatLabel = (label)-> label.replace /\s\([\w\s]+\)$/, ''
