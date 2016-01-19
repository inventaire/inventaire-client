labels = {}

module.exports =
  getLabel: (qid, lang)->
    data = labels[qid]
    if data? then return data[lang] or data.en

  setLabel: (qid, lang, label)->
    labels[qid] or= {}
    labels[qid][lang] = label
    return label

  getKnownQids: -> Object.keys labels
