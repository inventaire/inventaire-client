import { guessUriFromIsbn } from '#inventory/lib/importer/import_helpers'

export const getUserExistingItemsPathname = isbnData => {
  const uri = guessUriFromIsbn({ isbnData })
  const username = app.user.get('username')
  return `/inventory/${username}/${uri}`
}

export const statusContents = {
  newEntry: 'We could not identify this entry in the common bibliographic database. A new entry will be created',
  error: 'oups, something wrong happened',
  invalid: 'invalid ISBN',
  needInfo: 'need more information',
}
