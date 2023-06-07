import { entityTypeNameByType } from '#entities/lib/types/entities_types'

const properties = {}
export default properties

// editorTypes can stay permissive in the input
// and let the server do the strict validation
// Ex: isbns can be considered as simple strings before being validated server-side
const addProp = (
  property,
  editorType,
  searchType,
  multivalue = true,
  allowEntityCreation = false
) => {
  properties[property] = {
    editorType,
    searchType,
    property,
    multivalue,
    allowEntityCreation,
    entityTypeName: entityTypeNameByType[searchType]
  }
}

// Keep in sync with app/modules/entities/lib/editor/properties_per_type.js
// and server/controllers/entities/lib/properties.js@inventaire/inventaire

// # work
// author
addProp('wdt:P50', 'entity', 'humans', true, true)
// illustrator
addProp('wdt:P110', 'entity', 'humans', true, true)
// scenarist
addProp('wdt:P58', 'entity', 'humans', true, true)
// colorist
addProp('wdt:P6338', 'entity', 'humans', true, true)
// instance of
addProp('wdt:P31', 'entity', null, false, false)
// genre
addProp('wdt:P136', 'entity', 'genres', true, false)
// main subject
addProp('wdt:P921', 'entity', 'subjects', true, false)
// original language of work
addProp('wdt:P407', 'entity', 'languages', true, null)
// serie
addProp('wdt:P179', 'entity', 'series', false, true)
// series ordinal
addProp('wdt:P1545', 'positive-integer-string', null, false, false)
// based on
addProp('wdt:P144', 'entity', 'works', true, false)
// inspired by
addProp('wdt:P941', 'entity', 'works', true, false)
// editions (inverse of wdt:P629)
addProp('wdt:P747', 'fixed-entity', null, true, false)

// # edition
addProp('wdt:P629', 'entity', 'works', true, true)
// image
addProp('invp:P2', 'image', null, false, null)
// language
addProp('wdt:P407', 'entity', 'languages', true, null)
// isbn 13
addProp('wdt:P212', 'fixed-string', null, false, null)
// isbn 10
addProp('wdt:P957', 'fixed-string', null, false, null)
// collection
addProp('wdt:P195', 'entity', 'collections', false, true)
// distribution format
addProp('wdt:P437', 'entity', 'shortlist', false, false)
// date of publication
addProp('wdt:P577', 'simple-day', null, false, null)
// translator
addProp('wdt:P655', 'entity', 'humans', true, true)
// author of foreword
addProp('wdt:P2679', 'entity', 'humans', true, true)
// author of afterword
addProp('wdt:P2680', 'entity', 'humans', true, true)
// number of pages
addProp('wdt:P1104', 'positive-integer', null, false, null)
// number of volumes
addProp('wdt:P2635', 'positive-integer', null, false, null)

// # edition and collection
// publisher
addProp('wdt:P123', 'entity', 'publishers', true, true)
// title
addProp('wdt:P1476', 'string', null, false, null)
// subtitle
addProp('wdt:P1680', 'string', null, false, null)

// # human
// date of birth
addProp('wdt:P569', 'simple-day', null, false, null)
// date of death
addProp('wdt:P570', 'simple-day', null, false, null)
// languages of expression
addProp('wdt:P1412', 'entity', 'languages', true, null)
// influenced by
addProp('wdt:P737', 'entity', 'humans', true, true)
// movement
addProp('wdt:P135', 'entity', 'movements', true, false)

// # publisher
// founded by
addProp('wdt:P112', 'entity', 'humans', false, null)
// owned by
addProp('wdt:P127', 'entity', 'humans', false, null)
// inception
addProp('wdt:P571', 'simple-day', 'inception', false, null)
// dissolution
addProp('wdt:P576', 'simple-day', 'inception', false, null)
// ISBN publisher
addProp('wdt:P3035', 'string', null, true, null)

// # article
addProp('wdt:P1433', 'entity', null, false, null)

// # all
// official website
addProp('wdt:P856', 'url', null, false, null)

// # social networks
// Twitter account
addProp('wdt:P2002', 'external-id', null, false, null)
// Facebook account
addProp('wdt:P2013', 'external-id', null, false, null)
// Instagram username
addProp('wdt:P2003', 'external-id', null, false, null)
// YouTube channel ID
addProp('wdt:P2397', 'external-id', null, false, null)
// Mastodon address
addProp('wdt:P4033', 'external-id', null, false, null)

// # bibliographic databases
// BNF ID
addProp('wdt:P268', 'external-id', null, false, null)
// Open Library ID
addProp('wdt:P648', 'external-id', null, false, null)
