applyTransformers = require './apply_transformers'
applyDefaults = require './apply_defaults'
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
    metadata.url = '/' + route
    return metadata
  .then applyDefaults
  .then updateMetadata
  .finally metadataUpdateDone

updateMetadata = (metadata)->
  for key, value of metadata
    updateNodeType key, value
