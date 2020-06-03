# Metadata update is coupled to the needs of:
# - Prerender (https://github.com/inventaire/prerender), which itself aims to serve:
#   - search engines need status codes and redirection locations
#   - social media need metadata in different formats to show link previews:
#     - opengraph (https://ogp.me)
#     - twitter cards (https://developer.twitter.com/cards)
#   - other crawlers
# - browsers RSS feed detection
#
# For all the needs covered by Prerender, only the first update matters,
# but further updates might be needed for in browser metadata access,
# such as RSS feed detections

applyTransformers = require './apply_transformers'
updateNodeType = require './update_node_type'
{ currentRoute } = require 'lib/location'
initialRoute = currentRoute()
# Make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true
# Stop waiting if it takes more than 20 secondes: addresses cases
# where metadataUpdateDone would not have been called
setTimeout metadataUpdateDone, 20 * 1000
isPrerenderSession = window.navigator.userAgent.match('Prerender')?

lastRoute = null
updateRouteMetadata = (route, metadataPromise = {})->
  route = route.replace /^\//, ''
  # There should be no need to re-update metadata when the route stays the same
  if lastRoute is route then return

  # metadataPromise can be a promise or a simple object
  Promise.resolve metadataPromise
  .then applyMetadataUpdate(route)
  .finally metadataUpdateDone

applyMetadataUpdate = (route)-> (metadata = {})->
  if not prerenderReady and initialRoute isnt route then redirection = true

  if redirection then setPrerenderMeta 302, route

  if metadata.smallCardType
    metadata['twitter:card'] = 'summary'
    # Use a small image to force social media to display it small
    metadata.image = if metadata.image? then app.API.img metadata.image, 300, 300
    delete metadata.smallCardType

  unless metadata.title? then metadata = defaultMetadata()
  metadata.url or= "/#{route}"
  # image and rss can keep the default value, but description should be empty if no specific description can be found
  # to avoid just spamming with the default description
  metadata.description ?= ''
  updateMetadata metadata

defaultMetadata = ->
  title: 'Inventaire - ' + _.i18n 'your friends and communities are your best library'
  description: _.I18n 'make the inventory of your books and mutualize with your friends and communities into an infinite library!'
  image: 'https://inventaire.io/public/images/inventaire-books.jpg'
  rss: 'https://wiki.inventaire.io/blog.rss'
  'og:type': 'website'
  'twitter:card': 'summary_large_image'

updateMetadata = (metadata)->
  for key, value of metadata
    updateNodeType key, value
  return

setPrerenderMeta = (statusCode = 500, route)->
  if not isPrerenderSession or prerenderReady then return

  prerenderMeta = "<meta name='prerender-status-code' content='#{statusCode}'>"
  if statusCode is 302 and route?
    fullUrl = "#{document.location.origin}/#{route}".replace(/\/$/, '')
    # See https://github.com/prerender/prerender#httpheaders
    prerenderMeta += "<meta name='prerender-header' content='Location: #{fullUrl}'>"

  $('head').append prerenderMeta

setStatusCode = (statusCode, route)->
  setPrerenderMeta statusCode, route
  metadataUpdateDone()

module.exports = { updateRouteMetadata, setStatusCode }
