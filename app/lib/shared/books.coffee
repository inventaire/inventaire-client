module.exports = (_)->
  methods =
    isIsbn: (text)->
      cleanedText = @normalizeIsbn(text)
      if @isNormalizedIsbn cleanedText
        switch cleanedText.length
          when 10 then return 10
          when 13 then return 13
      return false

    normalizeIsbn: (text)-> text.trim().replace(/-/g, '').replace(/\s/g, '')
    isNormalizedIsbn: (text)->  /^(97(8|9))?\d{9}(\d|X)$/.test text

    uncurl: (url)-> url.replace('&edge=curl','')
    zoom: (url)-> url.replace('&zoom=1','&zoom=2')
