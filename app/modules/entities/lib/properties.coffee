module.exports = properties = {}

# editorTypes can stay permissive in the input
# and let the server do the strict validation
# Ex: isbns can be considered as simple strings before being validated server-side
addProp = (property, editorType, searchType, multivalue = true, allowEntityCreation = false)->
  properties[property] = { editorType, searchType, property, multivalue, allowEntityCreation }

# Keep in sync with app/modules/entities/lib/editor/properties_per_type.coffee
# and server/controllers/entities/lib/properties.coffee@inventaire/inventaire

## work
# author
addProp 'wdt:P50', 'entity', 'humans', true, true
# genre
addProp 'wdt:P136', 'entity', 'genres', true, false
# main subject
addProp 'wdt:P921', 'entity', 'subjects', true, false
# original language of work
addProp 'wdt:P364', 'entity', 'languages', true, null
# serie
addProp 'wdt:P179', 'entity', 'series', false, true
# series ordinal
addProp 'wdt:P1545', 'positive-integer-string', null, false, false
# based on
addProp 'wdt:P144', 'entity', 'works', true, false
# inspired by
addProp 'wdt:P941', 'entity', 'works', true, false
# editions (inverse of wdt:P629)
addProp 'wdt:P747', 'fixed-entity', null, true, false

## edition
addProp 'wdt:P629', 'entity', 'works', true, false
# title
addProp 'wdt:P1476', 'string', null, false, null
# subtitle
addProp 'wdt:P1680', 'string', null, false, null
# image
addProp 'invp:P2', 'image', null, false, null
# language
addProp 'wdt:P407', 'entity', 'languages', true, null
# isbn 13
addProp 'wdt:P212', 'fixed-string', null, false, null
# isbn 10
addProp 'wdt:P957', 'fixed-string', null, false, null
# publisher
addProp 'wdt:P123', 'entity', 'publishers', false, true
# collection
addProp 'wdt:P195', 'entity', 'collections', false, false
# date of publication
addProp 'wdt:P577', 'simple-day', null, false, null
# translator
addProp 'wdt:P655', 'entity', 'humans', true, true
# author of foreword
addProp 'wdt:P2679', 'entity', 'humans', true, true
# author of afterword
addProp 'wdt:P2680', 'entity', 'humans', true, true
# number of pages
addProp 'wdt:P1104', 'positive-integer', null, false, null
# number of volumes
addProp 'wdt:P2635', 'positive-integer', null, false, null

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
# Twitter account
addProp 'wdt:P2002', 'string', null, false, null
# Facebook account
addProp 'wdt:P2013', 'string', null, false, null
# Instagram username
addProp 'wdt:P2003', 'string', null, false, null
# YouTube channel ID
addProp 'wdt:P2397', 'string', null, false, null
# Mastodon address
addProp 'wdt:P4033', 'string', null, false, null

## work and human
addProp 'wdt:P856', 'string', null, false, null

## publisher
# founded by
addProp 'wdt:P112', 'entity', 'humans', false, null
# owned by
addProp 'wdt:P127', 'entity', 'humans', false, null
# Commons category
addProp 'wdt:P373', 'string', null, false, null
# inception
addProp 'wdt:P571', 'simple-day', 'inception', false, null
# dissolution
addProp 'wdt:P576', 'simple-day', 'inception', false, null
# ISBN publisher
addProp 'wdt:P3035', 'string', null, false, null
