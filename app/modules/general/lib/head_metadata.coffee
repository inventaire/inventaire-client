{ host } = require 'lib/urls'

metadataUpdate = (key, value)->
  _.log arguments, 'metadataUpdate'
  updates = _.forceObject key, value
  # Accept promises as possible values
  Promise.props updates
  .then (resolvedUpdates)->
    for k, v of resolvedUpdates
      updateMetadata k, v

updateMetadata = (key, value, noCompletion)->
  # _.log arguments, 'updateMetadata'
  unless key in possibleFields
    return _.error [key, value], 'invalid metadata data'

  unless value?
    _.warn "missing metadata value: #{key}"
    return

  if key is 'title'
    # as 'metadata:update' replaced 'document:title:change'
    # it should now also take the charge of page change side-effects
    app.execute 'track:page:view', value

  value = applyTransformers key, value, noCompletion
  # _.log value, "#{key} after transformers"
  for el in metaNodes[key]
    updateNodeContent value, el

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
  rss: [
    { selector: "[rel='alternate']", attribute: 'href' }
  ]


applyTransformers = (key, value, noCompletion)->
  if key in withTransformers then transformers[key](value, noCompletion)
  else value

possibleFields = Object.keys metaNodes

transformers =
  title: (value, noCompletion)->
    if noCompletion then value else "#{value} - Inventaire"
  url: (canonical)-> host + canonical
  image: (url)-> host + app.API.img(url)

withTransformers = Object.keys transformers


# make prerender wait before assuming everything is ready
# see https://prerender.io/documentation/best-practices
metadataUpdateNeeded = -> window.prerenderReady = false
metadataUpdateDone = -> window.prerenderReady = true

translateMetadata = ->
  tagline = _.i18n 'your friends and communities are your best library'
  metadataUpdate
    title: "Inventaire - #{tagline}"
    description: _.I18n 'make the inventory of your books and mutualize with your friends and communities into an infinite library!'

module.exports = ->
  unless app.user.lang is 'en' then translateMetadata()

  app.commands.setHandlers
    'metadata:update:needed': metadataUpdateNeeded
    'metadata:update': metadataUpdate
    'metadata:update:done': metadataUpdateDone
    'metadata:update:title': updateTitle
