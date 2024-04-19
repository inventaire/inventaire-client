import ISBN from 'isbn3'
import { findIsbns, isNormalizedIsbn, normalizeIsbn } from '#app/lib/isbn'

export const extractIsbns = text => {
  const isbns = findIsbns(text)
  if (isbns == null) return []

  return isbns
  .map(getIsbnData)
  .filter(obj => isNormalizedIsbn(obj.normalizedIsbn))
  .filter(firstOccurence({}))
}

export const getIsbnData = rawIsbn => {
  const normalizedIsbn = normalizeIsbn(rawIsbn)
  const data = ISBN.parse(normalizedIsbn)
  const isInvalid = (data == null)
  const isbn13 = isInvalid ? null : data.isbn13
  const isbn13h = isInvalid ? null : data.isbn13h
  return { rawIsbn, normalizedIsbn, isInvalid, isbn13, isbn13h }
}

const firstOccurence = normalizedIsbns13 => isbnData => {
  const { isbn13, isInvalid } = isbnData
  if (isInvalid) return true

  if (normalizedIsbns13[isbn13] != null) {
    return false
  } else {
    normalizedIsbns13[isbn13] = true
    return true
  }
}
