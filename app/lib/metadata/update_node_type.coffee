applyTransformers = require './apply_transformers'
{ metaNodes, possibleFields } = require './nodes'

previousValue = {}

module.exports = (key, value, noCompletion)->
  # Early return if the input is the same as previously
  if previousValue[key] is value then return
  previousValue[key] = value

  unless key in possibleFields
    return _.warn [ key, value ], 'invalid metadata data'

  unless value?
    _.warn "missing metadata value: #{key}"
    return

  if key is 'title'
    app.execute 'track:page:view', value

  value = applyTransformers key, value, noCompletion
  for el in metaNodes[key]
    updateNodeContent value, el

updateNodeContent = (value, el)->
  { selector, attribute } = el
  attribute or= 'content'

  document.querySelector(selector)?[attribute] = value
