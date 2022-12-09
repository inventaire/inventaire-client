import { without } from 'underscore'

export const entityTypeNameByType = {
  editions: 'edition',
  works: 'work',
  series: 'serie',
  humans: 'author',
  publishers: 'publisher',
  collections: 'collection'
}

export const entityTypeNameBySingularType = {
  edition: 'edition',
  work: 'work',
  serie: 'serie',
  human: 'author',
  publisher: 'publisher',
  collection: 'collection',
  subject: 'subject',
  genre: 'genre',
}

export const typesPossessiveForms = {
  work: "work's",
  edition: "edition's",
  serie: "series'",
  human: "author's",
  publisher: "publisher's",
  collection: "collection's"
}

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
  collection: 'wd:Q20655472'
}

export const allSearchableTypes = without(Object.keys(entityTypeNameByType), 'editions')
