module.exports = sharedLib('books')(_.preq, _)

module.exports.getImage = (data)->
    # data = encodeURIComponent(data)
    return @API.google.book(data)
    .then (res)=>
      if res.items?[0]?.volumeInfo?.imageLinks?.thumbnail?
        image = res.items[0].volumeInfo.imageLinks.thumbnail
        return {image: @normalize(image)}
      else console.warn "google book image not found for #{data}"
    .fail (err)-> _.logXhrErr err, "google book err for data: #{data}"

module.exports.getGoogleBooksDataFromIsbn = (isbn)->
    _.log cleanedIsbn = @cleanIsbnData isbn, 'cleaned ISBN!'
    unless cleanedIsbn? then return console.warn "bad isbn"

    return @API.google.book(cleanedIsbn)
    .then (res)=>
      if res.totalItems > 0
        # _.log res.items[0], 'getGoogleBooksDataFromIsbn rawItem'
        parsedItem = res.items[0].volumeInfo
        # _.log parsedItem, 'getGoogleBooksDataFromIsbn parsedItem'
        return @normalizeBookData parsedItem, isbn

      else console.warn "no item found for: #{cleanedIsbn}", res
    .fail (err)-> _.logXhrErr err, "google book err for isbn: #{isbn}"