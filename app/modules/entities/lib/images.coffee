wd_ = require 'lib/wikimedia/wikidata'
wikipedia_ = require 'lib/wikimedia/wikipedia'
commons_ = require 'lib/wikimedia/commons'

module.exports =
  openLibrary: (openLibraryId)->
    # _.log openLibraryId, 'ol'
    type = if @type is 'book' then 'book' else 'author'
    _.preq.get app.API.data.openLibraryCover(openLibraryId, type)
    .get 'url'
    .catch _.ErrorRethrow('openLibrary')

  wmCommons: (title)->
    # _.log title, 'wm'
    commons_.thumbData title, 1000
    .then (data)=>
      { thumbnail, author, license } = data
      setPictureCredits.call @, title, author, license
      return thumbnail
    .catch _.ErrorRethrow('wmCommons')

  enWikipedia: (enWpTitle)->
    # _.log enWpTitle, 'wp'
    wikipedia_.enWpImage enWpTitle
    .catch _.ErrorRethrow('enWikipedia')


setPictureCredits = (title, author, license)->
  if author? and license? then text = "#{author} - #{license}"
  else text = author or license

  @set 'pictureCredits',
    url: "https://commons.wikimedia.org/wiki/File:#{title}"
    text: text
