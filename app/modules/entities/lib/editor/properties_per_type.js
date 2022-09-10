// Keep in sync with app/modules/entities/lib/properties
// and server/controllers/entities/lib/properties/properties
// and server/controllers/entities/lib/properties/properties_per_type
// and server/lib/wikidata/allowlisted_properties
// and inventaire-i18n/original/wikidata.properties_list

const socialNetworks = {
  'wdt:P2002': {}, // Twitter account
  'wdt:P2013': {}, // Facebook account
  'wdt:P2003': {}, // Instagram username
  'wdt:P2397': {}, // YouTube channel ID
  'wdt:P4033': {}, // Mastodon address
}

// The order is meaningful:
const work = {
  'wdt:P50': {}, // author
  'wdt:P136': {}, // genre
  'wdt:P921': {}, // main subject
  'wdt:P407': { customLabel: 'original language' }, // original language of work
  'wdt:P577': { customLabel: 'first publication date' }, // publication date
  'wdt:P179': {}, // series
  'wdt:P1545': {}, // series ordinal
  'wdt:P144': {}, // based on
  'wdt:P941': {}, // inspired by
  'wdt:P856': {}, // official website
  'wdt:P268': {}, // BNF ID
  'wdt:P648': {}, // Open Library ID
  ...socialNetworks,
  // 'wdt:P31: {}' # instance of (=> works aliases)
  // 'wdt:P110': {} # illustrator
  // 'wdt:P1476': {} # title (using P407 lang)
  // 'wdt:P1680': {} # subtitle (using P407 lang)
  // 'wdt:P840': {} # narrative location
  // 'wdt:P674': {} # characters
}

export const propertiesPerType = {
  work,
  edition: {
    'wdt:P629': { customLabel: 'work from which this is an edition' }, // edition or translation of
    'wdt:P1476': { customLabel: 'edition title' },
    'wdt:P1680': { customLabel: 'edition subtitle' },
    'wdt:P407': { customLabel: 'edition language' },
    'invp:P2': { customLabel: 'cover' },
    // 'wdt:P31': {} # P31: instance of (=> edition aliases?)
    // P212 is used as unique ISBN field, accepting ISBN-10 but correcting server-side
    'wdt:P212': {}, // ISBN-13
    'wdt:P957': {}, // ISBN-10
    'wdt:P577': {}, // publication date
    'wdt:P123': {}, // publisher
    'wdt:P195': {}, // collection
    'wdt:P856': {}, // official website
    'wdt:P655': {}, // translator
    'wdt:P2679': {}, // author of foreword
    'wdt:P2680': {}, // author of afterword
    'wdt:P1104': {}, // number of pages
    'wdt:P2635': { customLabel: 'number of volumes' },
    'wdt:P268': {}, // BNF ID
    'wdt:P648': {}, // Open Library ID
  },

  human: {
    'wdt:P1412': {}, // languages of expression
    'wdt:P135': {}, // movement
    'wdt:P569': {}, // date of birth
    'wdt:P570': {}, // date of death
    'wdt:P737': {}, // influenced by
    'wdt:P856': {}, // official website
    'wdt:P268': {}, // BNF ID,
    'wdt:P648': {}, // Open Library ID
    ...socialNetworks
  },

  // Using omit instead of having a common list, extended for works, so that
  // the properties order isn't constrained by being part or not of the common properties
  serie: _.omit(work, [ 'wdt:P179', 'wdt:P1545', 'wdt:P747' ]),

  publisher: {
    'wdt:P856': {}, // official website
    'wdt:P112': {}, // founded by
    // Problematic to only autocomplete on humans as it is likely to be an organization
    // See https://github.com/inventaire/inventaire/issues/295
    // 'wdt:P127': {} # owned by
    'wdt:P571': { customLabel: 'date of foundation' }, // inception
    'wdt:P576': { customLabel: 'date of dissolution' }, // inception
    // Maybe, ISBN publisher prefix shouldn't be displayed but only used for administration(?)
    'wdt:P3035': {}, // ISBN publisher
    'wdt:P268': {}, // BNF ID
    ...socialNetworks,
  },

  collection: {
    'wdt:P1476': { customLabel: 'collection title' },
    'wdt:P1680': {}, // subtitle
    'wdt:P123': {}, // publisher
    'wdt:P921': {}, // main subject
    'wdt:P856': {}, // official website
    'wdt:P268': {}, // BNF ID
    ...socialNetworks,
  }
}

export const requiredPropertiesPerType = {
  edition: [ 'wdt:P629', 'wdt:P1476', 'wdt:P407' ],
  collection: [ 'wdt:P1476', 'wdt:P123' ]
}

export const propertiesCategories = {
  socialNetworks: { label: 'social networks' },
  bibliographicDatabases: { label: 'bibliographic databases' },
}

const propertiesPerCategory = {
  socialNetworks: Object.keys(socialNetworks),
  bibliographicDatabases: [
    'wdt:P268', // BNF ID
    'wdt:P648', // Open Library ID
  ]
}

const categoryPerProperty = {}

for (const [ key, categoryData ] of Object.entries(propertiesPerCategory)) {
  for (const property of categoryData) {
    categoryPerProperty[property] = key
  }
}

export const propertiesPerTypeAndCategory = {}

for (const [ type, propertiesData ] of Object.entries(propertiesPerType)) {
  propertiesPerTypeAndCategory[type] = {}
  for (const [ property, propertyData ] of Object.entries(propertiesData)) {
    const category = categoryPerProperty[property] || 'general'
    propertiesPerTypeAndCategory[type][category] = propertiesPerTypeAndCategory[type][category] || {}
    propertiesPerTypeAndCategory[type][category][property] = propertyData
  }
}
