module.exports = sharedLib('books')(_)


module.exports.getGoogleBooksDataFromIsbn = (isbn)->
  _.log cleanedIsbn = @cleanIsbnData isbn, 'cleaned ISBN!'
  unless cleanedIsbn? then return console.warn "bad isbn"

  return _.preq.get @API.google.book(cleanedIsbn)
  .then (res)=>
    if res.totalItems > 0
      # _.log res.items[0], 'getGoogleBooksDataFromIsbn rawItem'
      parsedItem = res.items[0].volumeInfo
      # _.log parsedItem, 'getGoogleBooksDataFromIsbn parsedItem'
      return @normalizeBookData parsedItem, isbn

    else console.warn "no item found for: #{cleanedIsbn}", res
  .fail (err)-> _.logXhrErr err, "google book err for isbn: #{isbn}"

images = []

module.exports.getImage = (data)->
  _.log data, 'data at getImage'
  images.push data
  lazyGetImages()
  return

getImages = ->
  _.preq.get app.API.entities.getImages(images)
  .then (res)->
    _.log res, 'res'
    if res? and _.isObject(res)
      for k, v of res
        app.vent.trigger "image:#{k}", v
    images = []
  .fail (err)-> _.logXhrErr err, "getImages err for images: #{images}"

lazyGetImages = _.debounce getImages, 100
