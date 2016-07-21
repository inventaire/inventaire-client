InvEntity = require '../models/inv_entity'

module.exports = (options)->
  { type, label } = options

  unless typeDefaultP31[type]?
    throw new Error "unknown type: #{type}"

  model = new Backbone.NestedModel
    labels: {}
    claims:
      'wdt:P31': typeDefaultP31[type]

  if label?
    # use the label we got as a label suggestion
    model.set "labels.#{app.user.lang}", label

  _.extend model,
    type: type
    creating: true
    propertiesShortlist: propertiesShortlists[type]
    setPropertyValue: InvEntity::setPropertyValue
    savePropertyValue: _.preq.resolve
    setLabel: InvEntity::setLabel
    saveLabel: _.preq.resolve

  return model


typeDefaultP31 =
  book: 'wd:Q571'

propertiesShortlists =
  book: ['wdt:P50']
