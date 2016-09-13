module.exports = properties = {}

addProp = (property, datatype, source, multivalue=true, allowEntityCreation=false)->
  properties[property] =
    datatype: datatype
    source: source
    property: property
    multivalue: multivalue
    allowEntityCreation: allowEntityCreation


# Keep in sync with app/modules/entities/lib/editor/properties_per_type.coffee

## book
# author
addProp 'wdt:P50', 'entity', 'humans', true, true
# genre
addProp 'wdt:P136', 'entity', 'genres', true, false
# main subject
addProp 'wdt:P921', 'entity', 'topics', true, false

## edition
# image
addProp 'wdt:P18', 'image', null, false, null
# publisher
addProp 'wdt:P123', 'string', null, false, null
# year of publication
addProp 'wdt:P577', 'string', null, false, null
# isbn 13
addProp 'wdt:P212', 'string', null, false, null
# isbn 10
addProp 'wdt:P957', 'string', null, false, null
# language of work
addProp 'wdt:P407', 'entity', 'languages', true, null
