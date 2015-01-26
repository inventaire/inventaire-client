Entity = require './entity'

module.exports = class IsbnEntity extends Entity
  prefix: 'isbn'
  initialize: ->
    @initLazySave()
    @findAPicture()

    @id = @get 'id'
    pathname = "/entity/#{@id}"

    if title = @get 'title'
      pathname += "/" + _.softEncodeURI(title)

    @set 'pathname', pathname

  findAPicture: ->
    pictures = @get 'pictures'
    unless _.isEmpty pictures
      @set 'pictures', pictures.map(app.lib.books.uncurl)
