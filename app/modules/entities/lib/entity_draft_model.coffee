editableEntity = require './inv/editable_entity'
createEntities = require './create_entities'

typeDefaultP31 =
  work: 'wd:Q571'

propertiesShortlists =
  work: ['wdt:P50']

module.exports =
  create: (options)->
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
      waitForSubentities: _.preq.resolved

    return model

  whitelistedTypes: Object.keys typeDefaultP31
