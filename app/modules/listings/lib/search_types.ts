import { typesBySection } from '#search/lib/search_sections'

const { work, serie, author, publisher } = typesBySection.entity

const searchTypesByListingType = {
  work: [ work, serie ],
  author: [ author ],
  publisher: [ publisher ],
}

export const getSearchType = listingType => searchTypesByListingType[listingType]
