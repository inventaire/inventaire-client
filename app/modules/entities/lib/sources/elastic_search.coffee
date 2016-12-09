module.exports = (type)->
  return searchType = (query)->
    { wikidata } = app.config.elasticsearch
    searchBase = "#{wikidata}/#{type}/_search"
    _.preq.post searchBase,
      query:
        bool:
          should: [
            { match_phrase_prefix: { _all: query } }
            { match: { _all: query } }
            { prefix: { _all: query.split(' ').slice(-1)[0] } }
          ]
    .then parse
    .then _.Log(type)

parse = (res)->
  res.hits.hits
  .map _.property('_source')
