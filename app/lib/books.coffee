Promises = require 'lib/promises'
module.exports = sharedLib('books')(Promises, _)

module.exports.getImage = (data)->
    # data = encodeURIComponent(data)
    return @API.google.book(data)
    .then (res)=>
      if res.items?[0]?.volumeInfo?.imageLinks?.thumbnail?
        image = res.items[0].volumeInfo.imageLinks.thumbnail
        return {image: @uncurl(image)}
      else console.warn "google book image not found for #{data}"
    .fail (err)-> _.logXhrErr err, "google book err for #{data}"
    .done()

module.exports.getGoogleBooksDataFromIsbn = (isbn)->
    _.log cleanedIsbn = @cleanIsbnData isbn, 'cleaned ISBN!'
    if cleanedIsbn?
      return @API.google.book(cleanedIsbn)
      .then (res)=>
        if res.totalItems > 0
          # _.log res.items[0], 'getGoogleBooksDataFromIsbn rawItem'
          parsedItem = res.items[0].volumeInfo
          # _.log parsedItem, 'getGoogleBooksDataFromIsbn parsedItem'
          return @normalizeBookData parsedItem, isbn
        else console.warn "no item found for: #{cleanedIsbn}", res
    else console.warn "bad isbn"