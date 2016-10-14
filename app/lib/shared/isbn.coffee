normalizeIsbn = (text)-> text.replace(/-/g, '').replace /\s/g, ''
isNormalizedIsbn = (text)-> /^(97(8|9))?\d{9}(\d|X)$/.test text

module.exports = (_)->
  isIsbn: (text)->
    unless _.isString text then return false
    cleanedText = normalizeIsbn text
    if isNormalizedIsbn cleanedText
      switch cleanedText.length
        when 10 then return 10
        when 13 then return 13
    return false

  normalizeIsbn: normalizeIsbn
  isNormalizedIsbn: isNormalizedIsbn
