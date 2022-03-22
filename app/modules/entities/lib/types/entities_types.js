export const entityTypeNameByType = {
  works: 'work',
  series: 'serie',
  humans: 'author',
  publishers: 'publisher',
  collections: 'collection'
}

export const entityTypeNameBySingularType = {
  work: 'work',
  serie: 'serie',
  human: 'author',
  publisher: 'publisher',
  collection: 'collection'
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
  if (type.slice(-1)[0] !== 's') type += 's'
  return type
}

export function typeHasName (type) {
  return type === 'human' || type === 'publisher'
}
