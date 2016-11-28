module.exports = properties = {}

# editorTypes can stay permissive in the input
# and let the server do the strict validation
# Ex: isbns can be considered as simple strings before being validated server-side
addProp = (property, editorType, source, multivalue=true, allowEntityCreation=false)->
  properties[property] = { editorType, source, property, multivalue, allowEntityCreation }

# Keep in sync with app/modules/entities/lib/editor/properties_per_type.coffee

## work
# author
addProp 'wdt:P50', 'entity', 'humans', true, true
# genre
addProp 'wdt:P136', 'entity', 'genres', true, false
# main subject
addProp 'wdt:P921', 'entity', 'topics', true, false

## edition
addProp 'wdt:P629', 'fixed-entity', null, false, null
# image
addProp 'wdt:P18', 'image', null, false, null
# publisher
addProp 'wdt:P123', 'entity', 'publishers', false, false
# year of publication
addProp 'wdt:P577', 'string', null, false, null
# isbn 13
addProp 'wdt:P212', 'string', null, false, null
# isbn 10
addProp 'wdt:P957', 'string', null, false, null
# language of work
addProp 'wdt:P407', 'entity', 'languages', true, null
# number of pages
addProp 'wdt:P1104', 'positive-integer', null, false, null
