isbn_ = require 'lib/isbn'
isbnPattern = /(97(8|9))?[\d\-]{9,13}([\dX])/g

module.exports = (text)->
  text.match isbnPattern
  .map getIsbnData
  .filter (obj)-> isbn_.isNormalizedIsbn(obj.normalized)
  .filter firstOccurence({})

getIsbnData = (rawIsbn)->
  normalized = isbn_.normalizeIsbn rawIsbn
  data =
    raw: rawIsbn
    normalized: normalized
    # the window.ISBN lib is made available by the isbn2 asset that
    # should have be fetched by app/modules/inventory/views/add/import
    isValid: window.ISBN.parse(normalized)?

firstOccurence = (isbnRoots)-> (isbnData)->
  { normalized:isbn } = isbnData
  # Find the part that would be in common between ISBN 10 and 13
  isbnRoot = if isbn.length is 13 then isbn[3..11] else isbn[0..8]
  # and use it to keep only one version of a given root
  if isbnRoots[isbnRoot]?
    return false
  else
    isbnRoots[isbnRoot] = true
    return true
