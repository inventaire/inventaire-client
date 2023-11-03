import { entityTypeNameByType } from '#entities/lib/types/entities_types'

const workAuthorRole = {
  editorType: 'entity',
  searchType: 'humans',
  multivalue: true,
  allowEntityCreation: true,
  specialEditActions: 'author-role',
}

export const propertiesEditorsConfigs = {
  'invp:P2': {
    editorType: 'image',
    multivalue: false,
  },
  // instance of
  'wdt:P31': {
    editorType: 'entity',
    multivalue: false,
    allowEntityCreation: false,
    // Further checks, such as preventing type changes, will be performed server-side
    canValueBeDeleted: ({ propertyClaims }) => propertyClaims.length > 1
  },
  // author
  'wdt:P50': workAuthorRole,
  // scenarist
  'wdt:P58': workAuthorRole,
  // editor
  'wdt:P98': workAuthorRole,
  // illustrator
  'wdt:P110': workAuthorRole,
  // founded by
  'wdt:P112': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: false,
  },
  // publisher
  'wdt:P123': {
    editorType: 'entity',
    searchType: 'publishers',
    multivalue: true,
    allowEntityCreation: true,
  },
  // owned by
  'wdt:P127': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: false,
  },
  // movement
  'wdt:P135': {
    editorType: 'entity',
    searchType: 'movements',
    multivalue: true,
    allowEntityCreation: false
  },
  // genre
  'wdt:P136': {
    editorType: 'entity',
    searchType: 'genres',
    multivalue: true,
    allowEntityCreation: false
  },
  // based on
  'wdt:P144': {
    editorType: 'entity',
    searchType: 'works',
    multivalue: true,
    allowEntityCreation: false,
  },
  // part of the series
  'wdt:P179': {
    editorType: 'entity',
    searchType: 'series',
    multivalue: false,
    allowEntityCreation: true,
  },
  // collection
  'wdt:P195': {
    editorType: 'entity',
    searchType: 'collections',
    multivalue: false,
    allowEntityCreation: true,
  },
  // ISBN-13
  'wdt:P212': {
    editorType: 'fixed-string',
    multivalue: false,
  },
  // Bibliothèque nationale de France ID
  'wdt:P268': {
    editorType: 'external-id',
    multivalue: false,
  },
  // language of work or name
  'wdt:P407': {
    editorType: 'entity',
    searchType: 'languages',
    multivalue: true,
  },
  // distribution format
  'wdt:P437': {
    editorType: 'entity',
    searchType: 'shortlist',
    multivalue: false,
    allowEntityCreation: false
  },
  // date of birth
  'wdt:P569': {
    editorType: 'simple-day',
    multivalue: false,
  },
  // date of death
  'wdt:P570': {
    editorType: 'simple-day',
    multivalue: false,
  },
  // inception
  'wdt:P571': {
    editorType: 'simple-day',
    searchType: 'inception',
    multivalue: false,
  },
  // dissolved, abolished or demolished date
  'wdt:P576': {
    editorType: 'simple-day',
    searchType: 'inception',
    multivalue: false,
  },
  // publication date
  'wdt:P577': {
    editorType: 'simple-day',
    multivalue: false,
  },
  // edition or translation of
  'wdt:P629': {
    editorType: 'entity',
    searchType: 'works',
    multivalue: true,
    allowEntityCreation: true,
  },
  // Open Library ID
  'wdt:P648': {
    editorType: 'external-id',
    multivalue: false,
  },
  // translator
  'wdt:P655': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: true,
    allowEntityCreation: true,
  },
  // influenced by
  'wdt:P737': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: true,
    allowEntityCreation: true,
  },
  // has edition or translation
  'wdt:P747': {
    editorType: 'fixed-entity',
    multivalue: true,
    allowEntityCreation: false
  },
  // official website
  'wdt:P856': {
    editorType: 'url',
    multivalue: false,
  },
  // main subject
  'wdt:P921': {
    editorType: 'entity',
    searchType: 'subjects',
    multivalue: true,
    allowEntityCreation: false
  },
  // inspired by
  'wdt:P941': {
    editorType: 'entity',
    searchType: 'works',
    multivalue: true,
    allowEntityCreation: false,
  },
  // ISBN-10
  'wdt:P957': {
    editorType: 'fixed-string',
    multivalue: false,
  },
  // number of pages
  'wdt:P1104': {
    editorType: 'positive-integer',
    multivalue: false,
  },
  // languages spoken, written or signed
  'wdt:P1412': {
    editorType: 'entity',
    searchType: 'languages',
    multivalue: true,
  },
  // published in
  'wdt:P1433': {
    editorType: 'entity',
    multivalue: false,
  },
  // title
  'wdt:P1476': {
    editorType: 'string',
    multivalue: false,
  },
  // series ordinal
  'wdt:P1545': {
    editorType: 'positive-integer-string',
    multivalue: false,
    allowEntityCreation: false
  },
  // subtitle
  'wdt:P1680': {
    editorType: 'string',
    multivalue: false,
  },
  // Twitter username
  'wdt:P2002': {
    editorType: 'external-id',
    multivalue: false,
  },
  // Instagram username
  'wdt:P2003': {
    editorType: 'external-id',
    multivalue: false,
  },
  // Facebook ID
  'wdt:P2013': {
    editorType: 'external-id',
    multivalue: false,
  },
  // YouTube channel ID
  'wdt:P2397': {
    editorType: 'external-id',
    multivalue: false,
  },
  // number of volumes/parts of this work
  'wdt:P2635': {
    editorType: 'positive-integer',
    multivalue: false,
  },
  // author of foreword
  'wdt:P2679': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: true,
    allowEntityCreation: true,
  },
  // author of afterword
  'wdt:P2680': {
    editorType: 'entity',
    searchType: 'humans',
    multivalue: true,
    allowEntityCreation: true,
  },
  // ISBN publisher prefix
  'wdt:P3035': {
    editorType: 'string',
    multivalue: true,
  },
  // Mastodon address
  'wdt:P4033': {
    editorType: 'external-id',
    multivalue: false,
  },
  // colorist
  'wdt:P6338': workAuthorRole,
  // letterer
  'wdt:P9191': workAuthorRole,
  // inker
  'wdt:P10836': workAuthorRole,
  // penciller
  'wdt:P10837': workAuthorRole,
}

for (const [ property, propertySettings ] of Object.entries(propertiesEditorsConfigs)) {
  propertySettings.property = property
  propertySettings.entityTypeName = entityTypeNameByType[propertySettings.searchType]
}
