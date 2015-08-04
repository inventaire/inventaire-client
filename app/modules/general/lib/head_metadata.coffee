metadataUpdate = (key, value)->
  updates = _.forceObject key, value
  _.log updates, 'metadataUpdate updates'
  for k, v of updates
    updateMetadata k, v

updateMetadata = (key, value)->
  unless key in possibleFields
    return _.error [key, value], 'invalid metadata data'

  if value?
    metaNodes[key].forEach updateNodeContent.bind(null, value)
  else
    _.warn value, "missing metadata value: #{key}"

  if key is 'title'
    document.title = "#{value} - Inventaire"

updateNodeContent = (value, selector)->
  document.querySelector(selector).content = value

updateTitle = (title)-> metadataUpdate 'title', title

metaNodes =
  title: [
    "[property='og:title']"
    "[name='twitter:title']"
  ],
  description: [
    "[property='og:description']"
    "[name='twitter:description']"
  ],
  image: [
    "[property='og:image']"
    "[name='twitter:image']"
  ]

possibleFields = Object.keys metaNodes

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
