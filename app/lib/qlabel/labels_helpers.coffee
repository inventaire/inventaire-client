labels = {}

module.exports =
  getLabel: (qid, lang)->
    data = labels[qid]
    if data?
      return data[lang] or data.en or data.original or _.pickOne(data)

  setLabel: (qid, lang, label)->
    labels[qid] or= {}
    labels[qid][lang] = label
    return label

  getKnownQids: -> Object.keys labels

  resetLabels: -> labels = {}
