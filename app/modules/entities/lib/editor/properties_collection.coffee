PropertyValues = require 'modules/entities/collections/property_values'

book =
  # instance of (=> books aliases)
  # P31: true
  # author
  P50: true
  # illustrator
  # P110: true
  # publication date
  # P577: false
  # series
  # P179: false

  # original language of work
  # P364: false
  # title (using P364 lang)
  # P1476: false
  # subtitle (using P364 lang)
  # P1680: false

  # follow
  # P155: false
  # is follow by
  # P156: false
  # genre
  P136: true
  # main subject
  # P921: true
  # narrative location
  # P840: true
  # characters
  # P674: true

edition =
  # instance of (=> edition aliases?)
  # P31: true
  # ISBN-13
  P212: false
  # ISBN-10
  P957: false
  # language of work
  P407: true

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection
  for prop, multivalue of book
    propertyModel = getPropertyModel entityModel, prop, multivalue
    propertiesCollection.add propertyModel

  return propertiesCollection

getPropertyModel = (entityModel, prop, multivalue)->
  propertyModel = new Backbone.Model
    property: prop
    multivalue: multivalue
  propertyModel.values = getPropertyValuesCollection entityModel, prop
  return propertyModel

getPropertyValuesCollection = (entityModel, prop)->
  claims = entityModel.get("claims.#{prop}") or []
  collection = new PropertyValues [],
    entity: entityModel
    property: prop

  collection.addClaimsValues claims

  return collection
