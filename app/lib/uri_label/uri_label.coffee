# internalized version of https://github.com/googleknowledge/qlabel

# How to:
# - Display html nodes with the hereafter defined class
#   and passing the node Qid as attribute
# - Trigger uriLabel.udpate to make it look for those elements
#   and replace their text by the best label it can find for the Qid

# keep in sync with app/modules/general/views/behaviors/templates/entity_value.hbs
className = 'uriLabel'
selector = ".#{className}"
attribute = 'data-uri'

wd_ = require 'lib/wikimedia/wikidata'
{ getLabel, setLabel, getKnownUris, resetLabels } = require './labels_helpers'

getEntitiesData = require 'modules/entities/lib/get_entities_data'

language = null
elements = null
refresh = false

getUris = (el)-> el.getAttribute attribute
getElements = -> document.querySelectorAll selector

gatherRequiredUris = -> [].map.call getElements(), getUris

display = ->
  # new elements might have appeared since gatherRequiredUris
  # was fired, and they could possibly have known uri, thus the interest
  # of re-querying elements
  for el in getElements()
    uri = getUris el
    if uri?
      label = getLabel uri, language
      if label?
        el.textContent = label
        # remove the class so that it doesn't re-appear in the next queries
        el.className = el.className.replace className, ''

  return

getEntities = (uris)->
  if uris.length is 0 then return

  getEntitiesData { uris, refresh }
  .then _.Log('getEntitiesData res')
  .then addEntitiesLabels
  # /!\ Not waiting for the update to run
  # but simply calling the debounced function
  .then debouncedUpdate
  .catch _.Error('uri_label getEntities err')

addEntitiesLabels = (entities)->
  for uri, entity of entities
    { labels, claims } = entity

    setEntityOriginalLang uri, claims, labels
    for lang, label of labels
      setLabel uri, lang, label

  return

setEntityOriginalLang = (uri, claims, labels)->
  originalLang = wd_.getOriginalLang claims
  originalValue = labels[originalLang]
  if originalValue? then setLabel uri, 'original', originalValue
  return

getMissingEntities = (uris)->
  missingUris = _.difference uris, getKnownUris()
  if missingUris.length > 0 then return getEntities uris
  else return _.preq.resolved

update = (lang)->
  language = lang
  uris = gatherRequiredUris()

  # Do not trigger display when no uri was found at this stage
  if uris.length is 0 then return

  getMissingEntities uris
  # Trigger display even if missingUris.length is 0
  # has there might be new elements with a known uri
  # but that have not be displayed yet
  .then display
  .catch _.Error('uriLabel err')

  # no need to return the promise
  return null

# Due to the specific flow of uriLabel, which updates are triggered from
# several places, it would be hard to pass a 'refresh' argument,
# thus this slightly hacky solution: one can open a 5 seconds window
# during which, qlabels will be taken directly from Wikidata API,
# thank to getEntities passing the refresh request to the local cache
refreshData = ->
  refresh = true
  resetLabels()
  setTimeout endRefreshMode, 5000

endRefreshMode = -> refresh = false

debouncedUpdate = _.debounce update, 200

module.exports =
  update: debouncedUpdate
  refreshData: refreshData

# share access to those labels with external modules
wd_.getLabel = (uris, lang)->
  # Make sure the uris were queried
  # TODO: work around the debounce to make sure the entities returned
  getEntities uris
  .then ->
    labels = _.forceArray(uris).map (uri)-> getLabel uri, lang
    return _.compact(labels).join ', '
