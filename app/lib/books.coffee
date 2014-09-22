module.exports = sharedLib 'books'

module.exports.getImage = (data)->
    data = encodeURIComponent(data)
    return $.getJSON app.API.google.book(data)
    .then (res)->
      if res.items[0].volumeInfo?.imageLinks?.thumbnail?
        image = res.items[0].volumeInfo.imageLinks.thumbnail
        return {image: image.replace('&edge=curl','')}
      else console.warn "google book image not found for #{data}"
    .fail (err)-> _.log err, "google book err for #{data}"
    .done()

module.exports.getGoogleBooksDataFromIsbn = (isbn)->
    _.log cleanedIsbn = @cleanIsbnData isbn, 'cleaned ISBN!'
    if cleanedIsbn?
      return $.getJSON app.API.google.book(cleanedIsbn)
      .then (res)=>
        if res.totalItems > 0
          # _.log res.items[0], 'getGoogleBooksDataFromIsbn rawItem'
          parsedItem = res.items[0].volumeInfo
          # _.log parsedItem, 'getGoogleBooksDataFromIsbn parsedItem'
          return @normalizeBookData parsedItem, isbn
        else throw "no item found for: #{cleanedIsbn}"
    else throw new Error "bad isbn"
