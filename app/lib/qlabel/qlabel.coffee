# internalized version of https://github.com/googleknowledge/qlabel

# How to:
# - Display html nodes with the hereafter defined class
#   and passing the node Qid as attribute
# - Trigger qlabel.udpate to make it look for those elements
#   and replace their text by the best label it can find for the Qid

# keep in sync with app/modules/general/views/behaviors/templates/wikidata_Q.hbs
className = 'qlabel'
selector = ".#{className}"
attribute = 'data-qid'

wd_ = require 'lib/wikidata'
{ getLabel, setLabel, getKnownQids, resetLabels } = require './labels_helpers'
language = null
elements = null
refresh = false

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

  return

# TODO deal with more than 50 entities
getWikidataEntities = (qids)->
  Entities.data.wd.local.get qids, null, refresh
  .then (entities)->
    for id, entity of entities
      { labels, claims } = entity
      setEntityOriginalLang id, claims, labels
      for lang, label of labels
        setLabel id, lang, label.value

    return

setEntityOriginalLang = (id, claims, labels)->
  originalLang = wd_.getOriginalLang claims, true
  originalValue = labels[originalLang]?.value
  if originalValue? then setLabel id, 'original', originalValue
  return

getMissingEntities = (qids)->
  missingQids = _.without qids, getKnownQids()
  if missingQids.length > 0 then return getWikidataEntities qids
  else return _.preq.resolved

update = (lang)->
  language = lang
  qids = gatherRequiredQids()

  # do not trigger display when no qid was found at this stage
  if qids.length is 0 then return

  getMissingEntities qids
  # trigger display even if missingQids.length is 0
  # has there might be new elements with a known qid
  # but that have not be displayed yet
  .then display
  .catch _.Error('qlabel err')

  # no need to return the promise
  return null

# Due to the specific flow of qlabel, which updates are triggered from
# several places, it would be hard to pass a 'refresh' argument,
# thus this slightly hacky solution: one can open a 5 seconds window
# during which, qlabels will be taken directly from Wikidata API,
# thank to getWikidataEntities passing the refresh request to the local cache
refreshData = ->
  refresh = true
  resetLabels()
  setTimeout endRefreshMode, 5000

endRefreshMode = -> refresh = false

module.exports =
  update: _.debounce update, 200
  refreshData: refreshData
