import { API } from '#app/api/api'
import preq from '#app/lib/preq'

export const getIsbnData = isbn => preq.get(API.data.isbn(isbn))

// Removing any non-alpha numeric characters, especially '-' and spaces
export function normalizeIsbn (text: string) {
  return text
  // Remove hypens
  .replace(/\W/g, '')
  // Make sure any 'x' is an X
  .toUpperCase()
}

export const isNormalizedIsbn = (text: string) => /^(97(8|9))?\d{9}(\d|X)$/.test(text)

// Stricter ISBN validation is done on the server but would be too expensive
// to do client-side: so the trade-off is that invalid ISBN
// might not be spotted client-side until refused by the server
export function looksLikeAnIsbn (text: unknown) {
  if (typeof text !== 'string') return false
  const cleanedText = normalizeIsbn(text)
  if (isNormalizedIsbn(cleanedText)) {
    if (cleanedText.length === 10) return 10
    if (cleanedText.length === 13) return 13
  }
  return false
}

// {9,13} would be enough, but since it is used this is an extractor, it makes sense to increase the possible scope to invalid isbns.
// Known cases: having five - instead of valid four.
export const findIsbns = (str: string) => str.match(/(97(8|9))?[\d-]{9,14}([\dX])/g) || []
