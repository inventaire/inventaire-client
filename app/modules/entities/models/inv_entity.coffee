Entity = require './entity'

module.exports = Entity.extend
  prefix: 'inv'
  initialize: ->
    # _.log @, 'init inv entity'
    @initLazySave()

    @id = @get('_id')

    canonical = pathname = "/entity/#{@prefix}:#{@id}"

    if title = @get('title')
      pathname += "/" + _.softEncodeURI(title)

    @set
      canonical: canonical
      pathname: pathname
      uri: "#{@prefix}:#{@id}"
      domain: 'inv'

  getAuthorsString: ->
    authors = @get 'authors'
    str = switch _.typeOf authors
      when 'string' then authors
      when 'array' then parseAuthors authors
      else ''

    return _.preq.resolve str

parseAuthors = (authors)->
  _.compact(authors)
  .map _.property('value')
  .join ', '
