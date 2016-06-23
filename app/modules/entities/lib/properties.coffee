module.exports = properties = {}

addProp = (property, type, source, multivalue=true, allowEntityCreation=false)->
  properties[property] =
    type: type
    source: source
    property: property
    multivalue: multivalue
    allowEntityCreation: allowEntityCreation

addProp 'wdt:P50', 'entity', 'humans', true, true
addProp 'wdt:P136', 'entity', 'genres', true, false
