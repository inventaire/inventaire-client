Entity = require './entity'
books_ = require 'lib/books'

module.exports = Entity.extend
  prefix: 'isbn'
  initialize: ->
    @initLazySave()

    @id = @get 'id'
    isbn = @get 'isbn'
    unless isbn?
      throw new Error "isbn entity doesn't have an isbn: #{@get('uri')}"

    @uri = @get('uri') or "isbn:#{isbn}"
    canonical = pathname = "/entity/#{@uri}"

    # required by 'save:entity:model'
    @set 'id', @get('isbn')
    @formatIfNew()

    @set
      canonical: canonical
      pathname: pathname
      # need to be set for inv-isbn entities
      uri: @uri
      pictures: [ @get('image') ]

  getAuthorsString: ->
    str = _.compact(@get('authors').map(parseAuthor)).join ', '
    return _.preq.resolve str

parseAuthor = (a)->
  switch a?.type
    when 'wikidata_id' then a.label
    when 'string' then a.value
    else null
