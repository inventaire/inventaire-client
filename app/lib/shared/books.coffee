module.exports = (Promises, _)->
  methods =
    API:
      google:
        book: (data)-> Promises.get "https://www.googleapis.com/books/v1/volumes/?q=#{data}"
      worldcat:
        # http://xisbn.worldcat.org/xisbnadmin/doc/api.htm
        isbnBaseRoute: 'http://xisbn.worldcat.org/webservices/xid/isbn/'
        to10: (isbn13)->
          Promises.get @isbnBaseRoute + "#{isbn13}?method=to10&format=json"
        to13: (isbn10)->
          Promises.get @isbnBaseRoute + "#{isbn10}?method=to13&format=json"
        hyphen: (isbn)->
          Promises.get @isbnBaseRoute + "#{isbn10}?method=hyphen&format=json"

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
      if _.typeString isbn
        cleanedIsbn = @normalizeIsbn(isbn)
        if @isNormalizedIsbn(cleanedIsbn)
          return cleanedIsbn
        else console.error 'isbn got an invalid value'

    normalizeBookData: (cleanedItem, isbn)->
      data =
        title: cleanedItem.title
        authors: cleanedItem.authors
        description: cleanedItem.description
        publisher: cleanedItem.publisher
        publishedDate: cleanedItem.publishedDate
        language: cleanedItem.language
        pictures: []

      if cleanedItem.industryIdentifiers?
        cleanedItem.industryIdentifiers.forEach (obj)->
          switch obj.type
            when 'ISBN_10' then data.P957 = obj.identifier
            when 'ISBN_13' then data.P212 = obj.identifier
            when 'OTHER' then otherId = obj.identifier

      isbn ||= data.P212 || data.P957

      if isbn? then data.id = data.uri = "isbn:#{isbn}"
      else if otherId? then data.id = data.uri = otherId
      else
        _.logRed 'no id found at normalizeBookData. Will be droped'
        return

      if cleanedItem.imageLinks?
         data.pictures.push cleanedItem.imageLinks.thumbnail

      return data

    uncurl: (url)-> url.replace('&edge=curl','')