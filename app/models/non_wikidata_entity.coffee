module.exports = class NonWikidataEntity extends Backbone.NestedModel
  # title
  # authors
  # pictures = []
  # uri
  # pathname
  # description

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
      uncurl = app.lib.books.uncurlGoogleBooksPictures
      @set 'pictures', pictures.map(uncurl)