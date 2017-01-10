editableEntity = require './inv/editable_entity'
createEntities = require './create_entities'

typeDefaultP31 =
  work: 'wd:Q571'
  serie: 'wd:Q277759'

propertiesShortlists =
  work: ['wdt:P50']
  serie: ['wdt:P50']

module.exports =
  create: (options)->
    { type, label, claims } = options

    # ALLOW TO SELECT SPECIFIC TYPE AT CREATION
    defaultP31 = typeDefaultP31[type]
    unless defaultP31?
      throw new Error "unknown type: #{type}"

    claims or= {}
    claimsProperties = Object.keys claims
    propertiesShortlist = propertiesShortlists[type].concat claimsProperties

    claims['wdt:P31'] = [ defaultP31 ]

    labels = {}
    if label?
      # use the label we got as a label suggestion
      labels[app.user.lang] = label

    model = new Backbone.NestedModel { type, labels, claims }

    _.extend model,
      type: type
      creating: true
      propertiesShortlist: propertiesShortlist
      setPropertyValue: editableEntity.setPropertyValue
      savePropertyValue: _.preq.resolve
      setLabel: editableEntity.setLabel
      saveLabel: _.preq.resolve
      create: -> createEntities.create @get('labels'), @get('claims')
      waitForSubentities: _.preq.resolved

    return model

  whitelistedTypes: Object.keys typeDefaultP31
