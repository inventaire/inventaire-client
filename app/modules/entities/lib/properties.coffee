module.exports = properties = {}

# editorTypes can stay permissive in the input
# and let the server do the strict validation
# Ex: isbns can be considered as simple strings before being validated server-side
addProp = (property, editorType, source, multivalue=true, allowEntityCreation=false)->
  properties[property] = { editorType, source, property, multivalue, allowEntityCreation }

# Keep in sync with app/modules/entities/lib/editor/properties_per_type.coffee
# and server/controllers/entities/lib/properties.coffee@inventaire/inventaire

## work
# author
addProp 'wdt:P50', 'entity', 'humans', true, true
# genre
addProp 'wdt:P136', 'entity', 'genres', true, false
# main subject
addProp 'wdt:P921', 'entity', 'topics', true, false
# serie
addProp 'wdt:P179', 'entity', 'series', false, true
# series ordinal
addProp 'wdt:P1545', 'positive-integer-string', null, false, false
# editions (inverse of wdt:P629)
addProp 'wdt:P747', 'fixed-entity', null, true, false
# original language of work
addProp 'wdt:P364', 'entity', 'languages', true, null

## edition
addProp 'wdt:P629', 'entity', 'works', true, false
# title
addProp 'wdt:P1476', 'string', null, false, null
# subtitle
addProp 'wdt:P1680', 'string', null, false, null
# image
addProp 'wdt:P18', 'image', null, false, null
# publisher
addProp 'wdt:P123', 'entity', 'publishers', false, false
# date of publication
addProp 'wdt:P577', 'simple-day', null, false, null
# isbn 13
addProp 'wdt:P212', 'fixed-string', null, false, null
# isbn 10
addProp 'wdt:P957', 'fixed-string', null, false, null
# language of work
addProp 'wdt:P407', 'entity', 'languages', true, null
# number of pages
addProp 'wdt:P1104', 'positive-integer', null, false, null
# author of foreword
addProp 'wdt:P2679', 'entity', 'humans', true, true
# author of afterword
addProp 'wdt:P2680', 'entity', 'humans', true, true

## human
# date of birth
addProp 'wdt:P569', 'simple-day', null, false, null
# date of death
addProp 'wdt:P570', 'simple-day', null, false, null
# languages of expression
addProp 'wdt:P1412', 'entity', 'languages', true, null
# influenced by
addProp 'wdt:P737', 'entity', 'humans', true, true
# movement
addProp 'wdt:P135', 'entity', 'movements', true, false
# genre (already added for works)
