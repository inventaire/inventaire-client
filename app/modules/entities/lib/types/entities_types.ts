import { without } from 'underscore'
import type { PluralizedIndexedEntityType } from '#server/types/entity'

export const entityTypeNameByType = {
  editions: 'edition',
  works: 'work',
  series: 'serie',
  humans: 'author',
  publishers: 'publisher',
  collections: 'collection',
} as const

export const entityTypeNameBySingularType = {
  article: 'article',
  edition: 'edition',
  work: 'work',
  serie: 'serie',
  human: 'author',
  publisher: 'publisher',
  collection: 'collection',
  movement: 'movement',
  subject: 'subject',
  genre: 'genre',
  // Pseudo-type existing only on the client for the needs of P7937 claim layouts
  form: 'form',
} as const

export const typesPossessiveForms = {
  work: "work's",
  edition: "edition's",
  serie: "series'",
  human: "author's",
  publisher: "publisher's",
  collection: "collection's",
} as const

export function pluralize (type) {
  if (!type) return
  if (type.slice(-1)[0] !== 's') type += 's'
  return type
}

export function typeHasName (type) {
  return type === 'human' || type === 'publisher'
}

export const typeDefaultP31 = {
  human: 'wd:Q5',
  work: 'wd:Q47461344',
  serie: 'wd:Q277759',
  edition: 'wd:Q3331189',
  publisher: 'wd:Q2085381',
  collection: 'wd:Q20655472',
} as const

export const allSearchableTypes = without(Object.keys(entityTypeNameByType), 'editions') as PluralizedIndexedEntityType[]

// Standalone meaning the entity URI can be a valid URL on its own (unlike claim based URLs)
export function isStandaloneEntityType (type) {
  return Object.keys(typeDefaultP31).includes(type)
}

export const typesString = {
  'wd:Q5': 'author',
  // works
  'wd:Q571': 'book',
  'wd:Q47461344': 'book',
  'wd:Q1004': 'comic book',
  'wd:Q8274': 'manga',
  'wd:Q49084': 'short story',
  // series
  'wd:Q277759': 'book series',
  'wd:Q14406742': 'comic book series',
  'wd:Q21198342': 'manga series',
} as const
