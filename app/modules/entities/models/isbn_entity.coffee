Entity = require './entity'

module.exports = Entity.extend
  prefix: 'isbn'
  initialize: ->
    @initLazySave()
    @findAPicture()

    # should expect data coming from both google books
    # and the local entities database (inv-isbn entities)
    @id = @get 'id'
    isbn = @get 'isbn'
    @uri = @get('uri') or "isbn:#{isbn}"
    pathname = "/entity/#{@uri}"

    if title = @get 'title'
      pathname += "/" + _.softEncodeURI(title)

    @set
      pathname: pathname
      domain: 'isbn'
      # need to be set for inv-isbn entities
      uri: @uri

  findAPicture: ->
    pictures = @get 'pictures'
    unless _.isEmpty pictures
      @set 'pictures', pictures.map(app.lib.books.uncurl)

  updateTwitterCard: ->
    # has to return a promise
    _.preq.start().then @executeTwitterCardUpdate.bind(@)

  executeTwitterCardUpdate: ->
    app.execute 'metadata:update',
      title: @get('title')
      description: @get('description')?[0..300]
      image: @get('pictures')?[0]
