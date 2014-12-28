module.exports = sharedLib('books')(_.preq, _)

module.exports.getImage = (data)->
  _.preq.get app.API.entities.getImage(data)
  .fail (err)-> _.logXhrErr err, "getImage err for data: #{data}"

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