module.exports = class NonWikidataEntity extends Backbone.NestedModel
  localStorage: new Backbone.LocalStorage 'isbn:Entities'
  initialize: ->
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