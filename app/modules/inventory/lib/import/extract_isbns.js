import { isNormalizedIsbn, normalizeIsbn } from '#lib/isbn'
// {9,13} would be enough, but since this is an extractor, it makes sense to enlarge the possible scope to invalid isbns.
// known cases: having five - instead of valid four.
const isbnPattern = /(97(8|9))?[\d-]{9,14}([\dX])/g
let API

export default API = {
  extractIsbns: text => {
    const isbns = text.match(isbnPattern)
    if (isbns == null) return []

    return isbns
    .map(API.getIsbnData)
    .filter(obj => isNormalizedIsbn(obj.normalizedIsbn))
    .filter(firstOccurence({}))
  },
  getIsbnData: rawIsbn => {
    const normalizedIsbn = normalizeIsbn(rawIsbn)
    // the window.ISBN lib is made available by the isbn3 asset that
    // should have be fetched by the consumer
    const data = window.ISBN.parse(normalizedIsbn)
    const isInvalid = (data == null)
    const isbn13 = isInvalid ? null : data.isbn13
    const isbn13h = isInvalid ? null : data.isbn13h
    return { rawIsbn, normalizedIsbn, isInvalid, isbn13, isbn13h }
  }
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
