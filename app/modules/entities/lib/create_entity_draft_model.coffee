editableEntity = require './inv/editable_entity'
createEntities = require './create_entities'

module.exports = (options)->
  { type, label } = options

  defaultP31 = typeDefaultP31[type]
  unless defaultP31?
    throw new Error "unknown type: #{type}"

  model = new Backbone.NestedModel
    labels: {}
    claims:
      'wdt:P31': [ defaultP31 ]

  if label?
    # use the label we got as a label suggestion
    model.set "labels.#{app.user.lang}", label

  _.extend model,
    type: type
    creating: true
    propertiesShortlist: propertiesShortlists[type]
    setPropertyValue: editableEntity.setPropertyValue
    savePropertyValue: _.preq.resolve
    setLabel: editableEntity.setLabel
    saveLabel: _.preq.resolve
    create: -> createEntities.create @get('labels'), @get('claims')

  return model

typeDefaultP31 =
  book: 'wd:Q571'

propertiesShortlists =
  book: ['wdt:P50']
