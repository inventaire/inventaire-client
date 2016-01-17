wd_ = require 'lib/wikidata'

module.exports =
  openLibrary: (openLibraryId)->
    _.log openLibraryId, 'ol'
    type = if @type is 'book' then 'book' else 'author'
    _.preq.get app.API.data.openLibraryCover(openLibraryId, type)
    .then _.property('url')
    .catch _.ErrorRethrow('openLibrary')

  wmCommons: (title)->
    _.log title, 'wm'
    wd_.wmCommonsThumbData title, 1000
    .then (data)=>
      { thumbnail, author, license } = data
      setPictureCredits.call @, title, author, license
      return thumbnail
    .catch _.ErrorRethrow('wmCommons')

  enWikipedia: (enWpTitle)->
    _.log enWpTitle, 'wp'
    wd_.enWpImage enWpTitle
    .catch _.ErrorRethrow('enWikipedia')


setPictureCredits = (title, author, license)->
  if author? and license? then text = "#{author} - #{license}"
  else text = author or license

  @set 'pictureCredits',
    url: "https://commons.wikimedia.org/wiki/File:#{title}"
    text: text
