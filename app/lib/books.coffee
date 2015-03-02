books_ = sharedLib('books')(_)

books_.getImage = (data)->
  images.push data
  lazyGetImages()
  return eventName(data)

images = []
eventName = (data)->
  # using a hash of the data to avoid firing the event several times
  # because the eventName contains spaces
  data = _.hashCode(data)
  return "image:#{data}"

getImages = ->
  _.log images, 'querying images'
  _.preq.get app.API.entities.getImages(images)
  .then spreadImages
  .catch _.LogXhrErr("getImages err for images: #{images}")

lazyGetImages = _.debounce getImages, 100

spreadImages = (res)->
  _.log res, 'data:getImages res'
  if res? and _.isArray(res)
    res.forEach (el)->
      if el?
        ev = eventName(el.data)
        app.vent.trigger ev, el.image
  images = []


books_.getIsbnEntities = (isbns)->
  isbns = isbns.map books_.normalizeIsbn
  _.preq.get app.API.entities.isbns(isbns)
  .catch _.LogXhrErr('getIsbnEntities err')

module.exports = books_