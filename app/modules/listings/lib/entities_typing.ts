import { typesBySection } from '#search/lib/search_sections'

const { work, serie, author, publisher } = typesBySection.entity

export const searchTypesByListingType = {
  work: [ work, serie ],
  author: [ author ],
  publisher: [ publisher ],
}

export const listingTypeByEntitiesTypes = {
  work: 'work',
  serie: 'work',
  human: 'author',
  publisher: 'publisher',
}

export const entitiesTypesByListingType = {
  work: [ 'work', 'serie' ],
  author: [ 'human' ],
  publisher: [ 'publisher' ],
}

export const i18nTypesKeys = {
  work: 'works and series',
  author: 'authors',
  publisher: 'publishers',
}

export const i18nSearchPlaceholderKeys = {
  work: 'Search for works or series',
  author: 'Search for authors',
  publisher: 'Search for publishers',
}
