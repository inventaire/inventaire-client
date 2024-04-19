import app from '#app/app'
import { guessUriFromIsbn } from '#inventory/lib/importer/import_helpers'

export const getUserExistingItemsPathname = isbnData => {
  const uri = guessUriFromIsbn({ isbnData })
  const username = app.user.get('username')
  return `/users/${username}/inventory/${uri}`
}

export const statusContents = {
  newEntry: 'We could not identify this entry in the common bibliographic database. A new entry will be created',
  error: 'oops, something wrong happened',
  needInfo: 'need more information',
}
