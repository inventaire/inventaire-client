# doc: https://dev.twitter.com/cards/types/summary-large-image
twitterData = ['card', 'site', 'creator', 'title', 'description', 'image']

updateTwitterCardData = (key, value)->
  updates = _.forceObject key, value
  _.log updates, 'updateTwitterCardData updates'
  for k, v of updates
    updateOneTwitterCardData k, v

updateOneTwitterCardData = (key, value)->
  unless key in twitterData
    return _.error [key, value], 'invalid twitter card data'

  if value?
    document.querySelector("[name='twitter:#{key}']").content = value
  else
    _.warn value, "missing twitter card value: #{key}"


# make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
metadataUpdateNeeded = -> window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true

module.exports = ->
  app.commands.setHandlers
    'update:twitter:card': updateTwitterCardData
    'metadata:update:needed': metadataUpdateNeeded
    'metadata:update:done': metadataUpdateDone
