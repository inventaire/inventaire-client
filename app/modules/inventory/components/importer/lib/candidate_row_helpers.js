import { guessUriFromIsbn } from '#inventory/lib/importer/import_helpers'

export const getUserExistingItemsPathname = isbnData => {
  const uri = guessUriFromIsbn({ isbnData })
  const username = app.user.get('username')
  return `/inventory/${username}/${uri}`
}
