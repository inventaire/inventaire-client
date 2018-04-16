isbn_ = require 'lib/isbn'
isbnPattern = /(97(8|9))?[\d\-]{9,13}([\dX])/g

module.exports = (text)->
  text.match isbnPattern
  .map getIsbnData
  .filter (obj)-> isbn_.isNormalizedIsbn(obj.normalizedIsbn)
  .filter firstOccurence({})

getIsbnData = (rawIsbn)->
  normalizedIsbn = isbn_.normalizeIsbn rawIsbn
  # the window.ISBN lib is made available by the isbn2 asset that
  # should have be fetched by app/modules/inventory/views/add/import
  data = window.ISBN.parse normalizedIsbn
  isInvalid = not data?
  isbn13 = if isInvalid then null else data.codes.isbn13
  return { rawIsbn, normalizedIsbn, isInvalid, isbn13 }

firstOccurence = (normalizedIsbns13)-> (isbnData)->
  { isbn13, isInvalid } = isbnData
  if isInvalid then return true

  if normalizedIsbns13[isbn13]?
    return false
  else
    normalizedIsbns13[isbn13] = true
    return true
