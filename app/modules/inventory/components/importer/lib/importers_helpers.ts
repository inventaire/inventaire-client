import { compact } from 'underscore'
import { getIsbnData } from '#inventory/lib/importer/extract_isbns'

export const getInvalidIsbnsString = isbns => {
  const isbnsData = isbns.map(isbn => {
    const isbnData = getIsbnData(isbn)
    if (isbnData.isInvalid) return isbn
  })
  return compact(isbnsData).join(', ')
}
