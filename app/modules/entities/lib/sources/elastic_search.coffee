dataUrl = 'https://data.inventaire.io'

module.exports = (type)->
  searchBase = "#{dataUrl}/wikidata/#{type}/_search"
  return searchType = (query)->
    _.preq.post searchBase,
      query:
        match_phrase_prefix:
          _all: query

    .then parse
    .then _.Log(type)

parse = (res)->
  res.hits.hits
  .map _.property('_source')
