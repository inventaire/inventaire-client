module.exports = properties = {}

addProp = (property, datatype, source, multivalue=true, allowEntityCreation=false)->
  properties[property] =
    datatype: datatype
    source: source
    property: property
    multivalue: multivalue
    allowEntityCreation: allowEntityCreation


# Keep in sync with app/modules/entities/lib/editor/properties_per_type.coffee

#book
addProp 'wdt:P50', 'entity', 'humans', true, true
addProp 'wdt:P136', 'entity', 'genres', true, false
addProp 'wdt:P921', 'entity', 'topics', true, false

#edition
addProp 'wdt:P212', 'string', null, false, null
addProp 'wdt:P957', 'string', null, false, null
addProp 'wdt:P407', 'entity', 'languages', true, null
