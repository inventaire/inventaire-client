# internalized version of https://github.com/googleknowledge/qlabel

# How to:
# - Display html nodes with the hereafter defined class
#   and passing the node Qid as attribute
# - Trigger uriLabel.update to make it look for those elements
#   and replace their text by the best label it can find for the Qid

# keep in sync with app/modules/general/views/behaviors/templates/entity_value.hbs
className = 'uriLabel'
selector = ".#{className}"
attribute = 'data-label-uri'

wd_ = require 'lib/wikimedia/wikidata'
{ getLabel, setLabel, getKnownUris, resetLabels, addPreviouslyMissingUris, wasntPrevisoulyMissing } = require './labels_helpers'

{ get:getEntitiesModels } = require 'modules/entities/lib/entities_models_index'

elements = null
refresh = false

getUris = (el)-> el.getAttribute attribute
getElements = -> document.querySelectorAll selector

gatherRequiredUris = -> [].map.call getElements(), getUris

display = ->
  # This runs only after i18n initialization so, app.user.lang should have been set
  { lang } = app.user
  # new elements might have appeared since gatherRequiredUris
  # was fired, and they could possibly have known uri, thus the interest
  # of re-querying elements
  for el in getElements()
    uri = getUris el
    if uri?
      unless lang? then throw new Error "lang isn't set"
      label = getLabel uri, lang
      if label?
        el.textContent = label
        # remove the class so that it doesn't re-appear in the next queries
        el.className = el.className.replace className, ''

  return

getEntities = (uris)->
  if uris.length is 0 then return

  getEntitiesModels { uris, refresh }
  .then addEntitiesLabels
  # /!\ Not waiting for the update to run
  # but simply calling the debounced function
  .then debouncedUpdate
  .catch _.Error('uri_label getEntities err')

addEntitiesLabels = (entitiesModels)->
  for uri, entityModel of entitiesModels
    [ labels, claims ] = entityModel.gets 'labels', 'claims'

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
  # Avoid refetching URIs: either the data is about to arrive
  # or the data is missing (in case of failing connection to Wikidata for instance)
  # and it would keep requesting it if not filtered-out
  urisToFetch = missingUris.filter wasntPrevisoulyMissing
  addPreviouslyMissingUris missingUris
  if urisToFetch.length > 0 then return getEntities urisToFetch
  else return _.preq.resolved

update = ->
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
