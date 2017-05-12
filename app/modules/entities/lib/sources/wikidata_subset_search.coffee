module.exports = (type)-> (search)->
  { wikidata } = app.config.elasticsearch
  searchBase = "#{wikidata}/#{type}/_search"
  _.preq.post searchBase,
    query:
      bool:
        should: [
          { match_phrase_prefix: { _all: search } }
          { match: { _all: search } }
          { prefix: { _all: search.split(' ').slice(-1)[0] } }
        ]
  .then parse
  .then _.Log(type)

parse = (res)->
  res.hits.hits
  .map _.property('_source')
