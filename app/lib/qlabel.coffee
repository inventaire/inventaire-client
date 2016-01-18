# internalized version of https://github.com/googleknowledge/qlabel

language = null
labels = {}
elements = []

# keep in sync with app/modules/general/views/behaviors/templates/wikidata_Q.hbs
className = 'qlabel'
selector = ".#{className}"
attribute = 'data-qid'

getQid = (el)->
  qid = el.getAttribute attribute
  if qid?
    el.qid = qid
    return qid
  else
    return null

gatherQids = ->
  elements = document.querySelectorAll selector
  return [].map.call elements, getQid

display = ->
  for el in elements
    { qid } = el
    if qid?
      label = getLabel qid, language
      if label?
        el.textContent = label
        # remove the class so that it doesn't re-appear in the update list
        el.className = el.className.replace className, ''

# TODO deal with more than 50 entities
wikidataLoader = (qids)->
  if qids.length > 0
    Entities.data.wd.local.get qids
    .then (entities)->
      for id, entity of entities
        for lang, label of entity.labels
          setLabel id, lang, label.value


setLabel = (qid, lang, label)->
  labels[qid] or= {}
  labels[qid][lang] = label
  return label

getLabel = (qid, lang)->
  data = labels[qid]
  if data? then return data[lang] or data.en

loadLabels = ->
  qids = gatherQids()
  # do not load already loaded qids
  qids = _.without qids, getKnownQids()
  return wikidataLoader qids

getKnownQids = -> Object.keys labels

update = (lang)->
  language = lang

  loadLabels()
  .then display
  .catch _.Error('qlabel err')

  # no need to return the promise
  return null


module.exports = ->
  update: _.debounce update, 200
  getKnownQids: getKnownQids
