WikidataEntity = require '../models/wikidata_entity'

module.exports = ->
  collection = app.entities.authors
  add = app.entities.add.bind app.entities

  remote = (query)->
    _.log query, 'query'
    # replace with https://www.wikidata.org/w/api.php?action=wbsearchentities&search=fred%20v&limit=20&format=json&language=la
    _.preq.get app.API.entities.search query, 'P31:Q5'
    .map (author)-> new WikidataEntity author
    .then add

    return

  source =
    collection: collection
    remote: remote
