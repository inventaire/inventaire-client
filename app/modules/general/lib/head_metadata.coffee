metadataUpdate = (key, value)->
  updates = _.forceObject key, value
  # _.log updates, 'metadataUpdate updates'
  for k, v of updates
    updateMetadata k, v

updateMetadata = (key, value)->
  unless key in possibleFields
    return _.error [key, value], 'invalid metadata data'

  if value?
    value = applyTransformers key, value
    metaNodes[key].forEach updateNodeContent.bind(null, value)

  else
    _.warn "missing metadata value: #{key}"

  if key is 'title'
    document.title = "#{value} - Inventaire"

updateNodeContent = (value, el)->
  { selector, attribute } = el
  attribute or= 'content'

  document.querySelector(selector)[attribute] = value

updateTitle = (title)-> metadataUpdate 'title', title


# attribute default to 'content'
metaNodes =
  title: [
    { selector: "[property='og:title']" },
    { selector: "[name='twitter:title']" }
  ]
  description: [
    { selector: "[property='og:description']" },
    { selector: "[name='twitter:description']" }
  ]
  image: [
    { selector: "[property='og:image']" },
    { selector: "[name='twitter:image']" }
  ]
  url: [
    { selector: "[property='og:url']" },
    { selector: "[rel='canonical']", attribute: 'href' }
  ]


applyTransformers = (key, value)->
  if key in withTransformers then transformers[key](value)
  else value

possibleFields = Object.keys metaNodes

transformers =
  url: (canonical)-> location.origin + canonical

withTransformers = Object.keys transformers


# make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
metadataUpdateNeeded = -> window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true

module.exports = ->
  app.commands.setHandlers
    'metadata:update:needed': metadataUpdateNeeded
    'metadata:update': metadataUpdate
    'metadata:update:done': metadataUpdateDone
    'metadata:update:title': updateTitle
