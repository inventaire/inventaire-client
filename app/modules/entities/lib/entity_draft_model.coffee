editableEntity = require './inv/editable_entity'
createEntities = require './create_entities'

typeDefaultP31 =
  work: 'wd:Q571'
  serie: 'wd:Q277759'
  edition: 'wd:Q3331189'

# TODO: allow to toggle the non-shortlisted properties
propertiesShortlists =
  work: [ 'wdt:P50' ]
  serie: [ 'wdt:P50' ]
  # edition: always display all properties

module.exports =
  create: (options)->
    { type, label, claims, next } = options

    # TODO: allow to select specific type at creation
    defaultP31 = typeDefaultP31[type]
    unless defaultP31?
      throw new Error "unknown type: #{type}"

    claims or= {}
    claimsProperties = Object.keys claims
    typeShortlist = propertiesShortlists[type]
    if typeShortlist?
      propertiesShortlist = propertiesShortlists[type].concat claimsProperties
    else
      propertiesShortlist = null

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

      # Methods required by app.navigateFromModel
      updateMetadata: -> { title: label or _.I18n('new entity') }

    # Attributes required by app.navigateFromModel
    model.set 'edit', _.buildPath('/entity/new', options)

    return model

  whitelistedTypes: Object.keys typeDefaultP31
