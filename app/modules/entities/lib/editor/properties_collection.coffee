PropertyValues = require 'modules/entities/collections/property_values'

book =
  # instance of (=> books aliases)
  # 'wdt:P31': true
  # author
  'wdt:P50': true
  # illustrator
  # 'wdt:P110': true
  # publication date
  # 'wdt:P577': false
  # series
  # 'wdt:P179': false

  # original language of work
  # 'wdt:P364': false
  # title (using P364 lang)
  # 'wdt:P1476': false
  # subtitle (using P364 lang)
  # 'wdt:P1680': false

  # follow
  # 'wdt:P155': false
  # is follow by
  # 'wdt:P156': false
  # genre
  'wdt:P136': true
  # main subject
  # 'wdt:P921': true
  # narrative location
  # 'wdt:P840': true
  # characters
  # 'wdt:P674': true

edition =
  # instance of (=> edition aliases?)
  # P31: true
  # ISBN-13
  'wdt:P212': false
  # ISBN-10
  'wdt:P957': false
  # language of work
  'wdt:P407': true

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
