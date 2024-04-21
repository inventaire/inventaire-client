import ISBN from 'isbn3'
import { findIsbns, isNormalizedIsbn, normalizeIsbn } from '#app/lib/isbn'

export function extractIsbns (text: string) {
  const isbns = findIsbns(text)
  return isbns
  .map(getIsbnData)
  .filter(obj => isNormalizedIsbn(obj.normalizedIsbn))
  .filter(firstOccurence({}))
}

export function getIsbnData (rawIsbn: string) {
  const normalizedIsbn = normalizeIsbn(rawIsbn)
  const data = ISBN.parse(normalizedIsbn)
  const isInvalid = (data == null)
  const isbn13 = isInvalid ? null : data.isbn13
  const isbn13h = isInvalid ? null : data.isbn13h
  return { rawIsbn, normalizedIsbn, isInvalid, isbn13, isbn13h }
}

const firstOccurence = (normalizedIsbns13: Record<string, boolean>) => (isbnData: ReturnType<typeof getIsbnData>) => {
  const { isbn13, isInvalid } = isbnData
  if (isInvalid) return true

  if (normalizedIsbns13[isbn13] != null) {
    return false
  } else {
    normalizedIsbns13[isbn13] = true
    return true
  }
}
