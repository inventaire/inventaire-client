module.exports = (_)->
  methods =
    API:
      google:
        book: (data)-> "https://www.googleapis.com/books/v1/volumes/?q=#{data}"
      worldcat:
        # http://xisbn.worldcat.org/xisbnadmin/doc/api.htm
        isbnBaseRoute: 'http://xisbn.worldcat.org/webservices/xid/isbn/'
        to10: (isbn13)-> @isbnBaseRoute + "#{isbn13}?method=to10&format=json"
        to13: (isbn10)-> @isbnBaseRoute + "#{isbn10}?method=to13&format=json"
        hyphen: (isbn)-> @isbnBaseRoute + "#{isbn10}?method=hyphen&format=json"

    isIsbn: (text)->
      cleanedText = @normalizeIsbn(text)
      if @isNormalizedIsbn cleanedText
        switch cleanedText.length
          when 10 then return 10
          when 13 then return 13
      return false

    normalizeIsbn: (text)-> text.trim().replace(/-/g, '').replace(/\s/g, '')
    isNormalizedIsbn: (text)-> /^([0-9]{10}|[0-9]{13})$/.test text

    cleanIsbnData: (isbn)->
      _.typeString isbn

      cleanedIsbn = @normalizeIsbn(isbn)
      if @isNormalizedIsbn(cleanedIsbn) then return cleanedIsbn
      else console.error 'isbn got an invalid value'

    normalizeBookData: (cleanedItem, isbn)->
      data = _.pick cleanedItem, 'title', 'authors', 'description', 'publisher', 'publishedDate', 'language'
      data.pictures = []

      {industryIdentifiers, imageLinks} = cleanedItem

      if industryIdentifiers?
        industryIdentifiers.forEach (obj)->
          switch obj.type
            when 'ISBN_10' then data.P957 = obj.identifier
            when 'ISBN_13' then data.P212 = obj.identifier
            when 'OTHER' then otherId = obj.identifier

      isbn or= data.P212 or data.P957

      if isbn? then data.id = data.uri = "isbn:#{isbn}"
      else if otherId? then data.id = data.uri = otherId
      else
        _.error 'no id found at normalizeBookData. Will be droped'
        return

      if imageLinks?
        url = @uncurl imageLinks.thumbnail
        data.pictures.push url
        data.pictures.push @zoom(url)

      return data

    uncurl: (url)-> url.replace('&edge=curl','')
    zoom: (url)-> url.replace('&zoom=1','&zoom=2')
    normalize: (url)->
      # cant use zoom as some picture return an ugly
      # image placeholder instead of a bigger picture
      # url = @zoom(url)
      return @uncurl url