# internalized version of https://github.com/googleknowledge/qlabel

language = null
elements = null
{ getLabel, setLabel, getKnownQids } = require './labels_helpers'

# keep in sync with app/modules/general/views/behaviors/templates/wikidata_Q.hbs
className = 'qlabel'
selector = ".#{className}"
attribute = 'data-qid'

getQid = (el)-> el.getAttribute attribute
getElements = -> document.querySelectorAll selector

gatherRequiredQids = ->
  return [].map.call getElements(), getQid

display = ->
  # new elements might have appeared since gatherRequiredQids
  # was fired, and they could possibly have known qid, thus the interest
  # of re-querying elements
  for el in getElements()
    qid = getQid el
    if qid?
      label = getLabel qid, language
      if label?
        el.textContent = label
        # remove the class so that it doesn't re-appear in the next queries
        el.className = el.className.replace className, ''

# TODO deal with more than 50 entities
getWikidataEntities = (qids)->
  Entities.data.wd.local.get qids
  .then (entities)->
    for id, entity of entities
      for lang, label of entity.labels
        setLabel id, lang, label.value

getMissingEntities = (qids)->
  missingQids = _.without qids, getKnownQids()
  _.log missingQids, 'qlabel:missingQids'

  if missingQids.length > 0 then return getWikidataEntities qids

update = (lang)->
  language = lang

  qids = gatherRequiredQids()
  _.log qids, 'qlabel:qids'

  # do not trigger display when no qid was found at this stage
  if qids.length is 0 then return

  _.preq.start
  .then -> getMissingEntities qids
  # trigger display even if missingQids.length is 0
  # has there might be new elements with a known qid
  # but that have not be displayed yet
  .then display
  .catch _.Error('qlabel err')

  # no need to return the promise
  return null


module.exports =
  update: _.debounce update, 200
