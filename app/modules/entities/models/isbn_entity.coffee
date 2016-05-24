Entity = require './entity'
books_ = require 'lib/books'

module.exports = Entity.extend
  prefix: 'isbn'
  initialize: ->
    @initLazySave()

    # should expect data coming from both google books
    # and the local entities database (inv-isbn entities)
    @id = @get 'id'
    isbn = @get 'isbn'
    unless isbn?
      throw new Error "isbn entity doesn't have an isbn: #{@get('uri')}"

    @uri = @get('uri') or "isbn:#{isbn}"
    canonical = pathname = "/entity/#{@uri}"

    # required by 'save:entity:model'
    @set 'id', @get('isbn')
    @formatIfNew()

    if title = @get 'title'
      pathname += "/" + _.softEncodeURI(title)

    @set
      canonical: canonical
      pathname: pathname
      domain: 'isbn'
      # need to be set for inv-isbn entities
      uri: @uri

  formatAsync: ->
    @initPictures()

  initPictures: ->
    pictures = @get('pictures') or []
    @set 'pictures', pictures

    books_.getImage @uri
    .map _.property('image')
    .then pickBestPictures.bind(null, pictures)
    .then @set.bind(@, 'pictures')

  getAuthorsString: ->
    str = _.compact(@get('authors').map(parseAuthor)).join ', '
    return _.preq.resolve str

parseAuthor = (a)->
  switch a?.type
    when 'wikidata_id' then a.label
    when 'string' then a.value
    else null

pickBestPictures = (pictures, newPictures)->
  pictures = _.uniq pictures.concat(newPictures)
  filtered = pictures.filter discardGoogleBooksPictures
  # if we can do without Google Books low quality pictures, that's better
  if filtered.length > 0 then return filtered
  else return pictures

gBooks = /books\.google\.com/
discardGoogleBooksPictures = (picture)-> not gBooks.test picture
