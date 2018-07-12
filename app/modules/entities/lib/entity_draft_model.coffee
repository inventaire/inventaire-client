editableEntity = require './inv/editable_entity'
createEntities = require './create_entities'
properties = require './properties'

typeDefaultP31 =
  human: 'wd:Q5'
  work: 'wd:Q571'
  serie: 'wd:Q277759'
  edition: 'wd:Q3331189'

propertiesShortlists =
  human: [ 'wdt:P1412' ]
  work: [ 'wdt:P50' ]
  serie: [ 'wdt:P50' ]
  edition: [ 'wdt:P18', 'wdt:P407', 'wdt:P1476', 'wdt:P577' ]

module.exports =
  create: (options)->
    { type, label, claims, next, relation } = options

    # TODO: allow to select specific type at creation
    defaultP31 = typeDefaultP31[type]
    unless defaultP31?
      throw new Error "unknown type: #{type}"

    claims or= {}
    claims['wdt:P31'] = [ defaultP31 ]

    labels = {}
    if label?
      # use the label we got as a label suggestion
      labels[app.user.lang] = label

    model = new Backbone.NestedModel { type, labels, claims }

    _.extend model,
      type: type
      creating: true
      # The property that links this entity to another entity being created
      relation: relation
      propertiesShortlist: getPropertiesShortlist type, claims
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

getPropertiesShortlist = (type, claims)->
  typeShortlist = propertiesShortlists[type]
  unless typeShortlist? then return null

  claimsProperties = Object.keys(claims).filter nonFixedEditor
  propertiesShortlist = propertiesShortlists[type].concat claimsProperties
  # If a serie was passed in the claims, invite to add an ordinal
  if 'wdt:P179' in claimsProperties then propertiesShortlist.push 'wdt:P1545'

  return propertiesShortlist

nonFixedEditor = (prop)->
  # Testing properties[prop] existance as some properties don't
  # have an editor. Ex: wdt:P31
  editorType = properties[prop]?.editorType
  unless editorType then return false

  # Filter-out fixed editor: 'fixed-entity', 'fixed-string'
  if editorType.split('-')[0] is 'fixed' then return false

  return true
