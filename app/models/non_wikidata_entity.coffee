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
      @set 'pictures', pictures.map(uncurlGoogleBooksPictures)
    else
      data = [@get('title')]
      @get('authors').forEach (author)-> data.push(author)
      app.lib.books.getLuckyImage data.join(' ')
      .then (res)=>
        if res?.image?
          pictures = @get('pictures')
          pictures.push res.image
          @set('pictures', pictures)
      .fail (err)-> _.log err, "err after bookAPI.getLuckyImage for #{label}"
      .done()


uncurlGoogleBooksPictures = (url)-> url.replace('&edge=curl','')
