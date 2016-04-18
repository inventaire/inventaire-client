Filterable = require 'modules/general/models/filterable'

# make models use 'id' as idAttribute so that search results
# automatically dedupplicate themselves
SearchResult = Filterable.extend
  idAttribute: 'id'
  asMatchable: ->
    _.chain @gets('label', 'title', 'aliases')
    # aliases might be undefined
    .compact()
    # if defined, aliases is an array
    .flatten()
    .uniq()
    .value()

collection = new Backbone.Collection [], { model: SearchResult }
searches = []

module.exports = ->

  remote = (query)->
    _.log query, 'query'
    if query in searches
      _.log query, 'already queried'
      # keep a consistant interface by returning only promises
      return _.preq.resolved

    searches.push query

    # replace with https://www.wikidata.org/w/api.php?action=wbsearchentities&search=fred%20v&limit=20&format=json&language=la
    url = wdk.searchEntities query, app.user.lang, 10

    _.preq.get url
    .then _.property('search')
    .filter testBlacklist
    .then collection.add.bind(collection)

  source =
    collection: collection
    remote: remote

testBlacklist = (result)->
  anyMatch = _.any blacklist, (regex)-> regex.test result.description
  return not anyMatch

blacklist = [
  # matching disambiguation in EN, ES, IT
  /sambigu/
  # FR
  /homonymie/
  # DE
  /Begriffsklärungsseite/
]
