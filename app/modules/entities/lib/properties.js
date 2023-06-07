import { entityTypeNameByType } from '#entities/lib/types/entities_types'

const properties = {
  'invp:P2': {
    editorType: 'image',
    property: 'invp:P2',
    multivalue: false,
  },
  // instance of
  'wdt:P31': {
    editorType: 'entity',
    property: 'wdt:P31',
    multivalue: false,
    allowEntityCreation: false
  },
  // author
  'wdt:P50': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P50',
    multivalue: true,
    allowEntityCreation: true,
  },
  // screenwriter
  'wdt:P58': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P58',
    multivalue: true,
    allowEntityCreation: true,
  },
  // illustrator
  'wdt:P110': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P110',
    multivalue: true,
    allowEntityCreation: true,
  },
  // founded by
  'wdt:P112': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P112',
    multivalue: false,
  },
  // publisher
  'wdt:P123': {
    editorType: 'entity',
    searchType: 'publishers',
    property: 'wdt:P123',
    multivalue: true,
    allowEntityCreation: true,
  },
  // owned by
  'wdt:P127': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P127',
    multivalue: false,
  },
  // movement
  'wdt:P135': {
    editorType: 'entity',
    searchType: 'movements',
    property: 'wdt:P135',
    multivalue: true,
    allowEntityCreation: false
  },
  // genre
  'wdt:P136': {
    editorType: 'entity',
    searchType: 'genres',
    property: 'wdt:P136',
    multivalue: true,
    allowEntityCreation: false
  },
  // based on
  'wdt:P144': {
    editorType: 'entity',
    searchType: 'works',
    property: 'wdt:P144',
    multivalue: true,
    allowEntityCreation: false,
  },
  // part of the series
  'wdt:P179': {
    editorType: 'entity',
    searchType: 'series',
    property: 'wdt:P179',
    multivalue: false,
    allowEntityCreation: true,
  },
  // collection
  'wdt:P195': {
    editorType: 'entity',
    searchType: 'collections',
    property: 'wdt:P195',
    multivalue: false,
    allowEntityCreation: true,
  },
  // ISBN-13
  'wdt:P212': {
    editorType: 'fixed-string',
    property: 'wdt:P212',
    multivalue: false,
  },
  // Bibliothèque nationale de France ID
  'wdt:P268': {
    editorType: 'external-id',
    property: 'wdt:P268',
    multivalue: false,
  },
  // language of work or name
  'wdt:P407': {
    editorType: 'entity',
    searchType: 'languages',
    property: 'wdt:P407',
    multivalue: true,
  },
  // distribution format
  'wdt:P437': {
    editorType: 'entity',
    searchType: 'shortlist',
    property: 'wdt:P437',
    multivalue: false,
    allowEntityCreation: false
  },
  // date of birth
  'wdt:P569': {
    editorType: 'simple-day',
    property: 'wdt:P569',
    multivalue: false,
  },
  // date of death
  'wdt:P570': {
    editorType: 'simple-day',
    property: 'wdt:P570',
    multivalue: false,
  },
  // inception
  'wdt:P571': {
    editorType: 'simple-day',
    searchType: 'inception',
    property: 'wdt:P571',
    multivalue: false,
  },
  // dissolved, abolished or demolished date
  'wdt:P576': {
    editorType: 'simple-day',
    searchType: 'inception',
    property: 'wdt:P576',
    multivalue: false,
  },
  // publication date
  'wdt:P577': {
    editorType: 'simple-day',
    property: 'wdt:P577',
    multivalue: false,
  },
  // edition or translation of
  'wdt:P629': {
    editorType: 'entity',
    searchType: 'works',
    property: 'wdt:P629',
    multivalue: true,
    allowEntityCreation: true,
  },
  // Open Library ID
  'wdt:P648': {
    editorType: 'external-id',
    property: 'wdt:P648',
    multivalue: false,
  },
  // translator
  'wdt:P655': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P655',
    multivalue: true,
    allowEntityCreation: true,
  },
  // influenced by
  'wdt:P737': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P737',
    multivalue: true,
    allowEntityCreation: true,
  },
  // has edition or translation
  'wdt:P747': {
    editorType: 'fixed-entity',
    property: 'wdt:P747',
    multivalue: true,
    allowEntityCreation: false
  },
  // official website
  'wdt:P856': {
    editorType: 'url',
    property: 'wdt:P856',
    multivalue: false,
  },
  // main subject
  'wdt:P921': {
    editorType: 'entity',
    searchType: 'subjects',
    property: 'wdt:P921',
    multivalue: true,
    allowEntityCreation: false
  },
  // inspired by
  'wdt:P941': {
    editorType: 'entity',
    searchType: 'works',
    property: 'wdt:P941',
    multivalue: true,
    allowEntityCreation: false,
  },
  // ISBN-10
  'wdt:P957': {
    editorType: 'fixed-string',
    property: 'wdt:P957',
    multivalue: false,
  },
  // number of pages
  'wdt:P1104': {
    editorType: 'positive-integer',
    property: 'wdt:P1104',
    multivalue: false,
  },
  // languages spoken, written or signed
  'wdt:P1412': {
    editorType: 'entity',
    searchType: 'languages',
    property: 'wdt:P1412',
    multivalue: true,
  },
  // published in
  'wdt:P1433': {
    editorType: 'entity',
    property: 'wdt:P1433',
    multivalue: false,
  },
  // title
  'wdt:P1476': {
    editorType: 'string',
    property: 'wdt:P1476',
    multivalue: false,
  },
  // series ordinal
  'wdt:P1545': {
    editorType: 'positive-integer-string',
    property: 'wdt:P1545',
    multivalue: false,
    allowEntityCreation: false
  },
  // subtitle
  'wdt:P1680': {
    editorType: 'string',
    property: 'wdt:P1680',
    multivalue: false,
  },
  // Twitter username
  'wdt:P2002': {
    editorType: 'external-id',
    property: 'wdt:P2002',
    multivalue: false,
  },
  // Instagram username
  'wdt:P2003': {
    editorType: 'external-id',
    property: 'wdt:P2003',
    multivalue: false,
  },
  // Facebook ID
  'wdt:P2013': {
    editorType: 'external-id',
    property: 'wdt:P2013',
    multivalue: false,
  },
  // YouTube channel ID
  'wdt:P2397': {
    editorType: 'external-id',
    property: 'wdt:P2397',
    multivalue: false,
  },
  // number of volumes/parts of this work
  'wdt:P2635': {
    editorType: 'positive-integer',
    property: 'wdt:P2635',
    multivalue: false,
  },
  // author of foreword
  'wdt:P2679': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P2679',
    multivalue: true,
    allowEntityCreation: true,
  },
  // author of afterword
  'wdt:P2680': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P2680',
    multivalue: true,
    allowEntityCreation: true,
  },
  // ISBN publisher prefix
  'wdt:P3035': {
    editorType: 'string',
    property: 'wdt:P3035',
    multivalue: true,
  },
  // Mastodon address
  'wdt:P4033': {
    editorType: 'external-id',
    property: 'wdt:P4033',
    multivalue: false,
  },
  // colorist
  'wdt:P6338': {
    editorType: 'entity',
    searchType: 'humans',
    property: 'wdt:P6338',
    multivalue: true,
    allowEntityCreation: true,
  },
}

for (const settings of Object.values(properties)) {
  settings.entityTypeName = entityTypeNameByType[settings.searchType]
}

export default properties
