metadataUpdate = (key, value)->
  updates = _.forceObject key, value
  for k, v of updates
    updateMetadata k, v

updateMetadata = (key, value, noCompletion)->
  # _.log arguments, 'updateMetadata'
  unless key in possibleFields
    return _.error [key, value], 'invalid metadata data'

  unless value?
    _.warn "missing metadata value: #{key}"
    return

  value = applyTransformers key, value, noCompletion
  metaNodes[key].forEach updateNodeContent.bind(null, value)

updateNodeContent = (value, el)->
  { selector, attribute } = el
  attribute or= 'content'

  document.querySelector(selector)[attribute] = value

updateTitle = (title, noCompletion)-> updateMetadata 'title', title, noCompletion


# attribute default to 'content'
metaNodes =
  title: [
    { selector: 'title', attribute: 'text'},
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


applyTransformers = (key, value, noCompletion)->
  if key in withTransformers then transformers[key](value, noCompletion)
  else value

possibleFields = Object.keys metaNodes

transformers =
  title: (value, noCompletion)->
    if noCompletion then value else "#{value} - Inventaire"
  url: (canonical)-> location.origin + canonical
  image: (url)->
    if _.localUrl url then return "#{location.origin}#{url}"
    else url

withTransformers = Object.keys transformers


# make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
metadataUpdateNeeded = -> window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true

initTitle = ->
  punchline = _.i18n 'your friends and communities are your best library'
  updateTitle "Inventaire - #{punchline}", true

module.exports = ->
  initTitle()

  app.commands.setHandlers
    'metadata:update:needed': metadataUpdateNeeded
    'metadata:update': metadataUpdate
    'metadata:update:done': metadataUpdateDone
    'metadata:update:title': updateTitle
