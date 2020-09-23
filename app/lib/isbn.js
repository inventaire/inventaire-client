const getIsbnData = isbn => _.preq.get(app.API.data.isbn(isbn))

// Removing any non-alpha numeric characters, especially '-' and spaces
const normalizeIsbn = text => text
// Remove hypens
.replace(/\W/g, '')
// Make sure any 'x' is an X
.toUpperCase()

const isNormalizedIsbn = text => /^(97(8|9))?\d{9}(\d|X)$/.test(text)

// Stricter ISBN validation is done on the server but would be too expensive
// to do client-side: so the trade-off is that invalid ISBN
// might not be spotted client-side until refused by the server
const looksLikeAnIsbn = function (text) {
  if (typeof text !== 'string') { return false }
  const cleanedText = normalizeIsbn(text)
  if (isNormalizedIsbn(cleanedText)) {
    switch (cleanedText.length) {
    case 10: return 10; break
    case 13: return 13; break
    }
  }
  return false
}

export { getIsbnData, normalizeIsbn, isNormalizedIsbn, looksLikeAnIsbn }
