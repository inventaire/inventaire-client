applyTransformers = require './apply_transformers'
updateNodeType = require './update_node_type'
# Make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true
# Stop waiting if it takes more than 30 secondes: addresses cases
# where metadataUpdateDone would not have been called
setTimeout metadataUpdateDone, 30 * 1000

lastRoute = null
module.exports = (route, metadataPromise = {})->
  # There should be no need to re-update metadata when the route stays the same
  if lastRoute is route then return

  # metadataPromise can be a promise or a simple object
  Promise.resolve metadataPromise
  .then (metadata)->
    metadata.url or= (if route[0] is '/' then route else "/#{route}")
    return metadata
  .then applyDefaults
  .then updateMetadata
  .finally metadataUpdateDone

updateMetadata = (metadata)->
  for key, value of metadata
    updateNodeType key, value

applyDefaults = (metadata)->
  unless metadata?.title? then return defaultMetadata()
  # image and rss can keep the default value, but description should be empty if no specific description can be found
  # to avoid just spamming with the default description
  metadata.description ?= ''
  return metadata

defaultMetadata = ->
  title: 'Inventaire - ' + _.i18n 'your friends and communities are your best library'
  description: _.I18n 'make the inventory of your books and mutualize with your friends and communities into an infinite library!'
  image: 'https://inventaire.io/public/images/inventaire-books.jpg'
  rss: 'http://blog.inventaire.io/rss'
