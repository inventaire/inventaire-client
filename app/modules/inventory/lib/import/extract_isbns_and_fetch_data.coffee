fetchEntitiesSequentially = require './fetch_entities_sequentially'
extractIsbns = require './extract_isbns'
getCandidatesFromEntitiesDocs = require './get_candidates_from_entities_docs'
isbn2 = require('lib/get_assets')('isbn2')

module.exports = (text)->
  isbn2.get()
  .then ->
    # window.ISBN should now be initalized
    isbnsData = extractIsbns text

    if isbnsData.length is 0 then return []

    fetchEntitiesSequentially isbnsData
    .then parseResults

parseResults = (data)->
  { results, isbnsIndex } = data
  newCandidates = getCandidatesFromEntitiesDocs results.entities, isbnsIndex

  return newCandidates
    .concat results.notFound, results.invalidIsbn
    # Make sure to display candidates in the order they where input
    # to help the user fill the missing information
    .sort byIndex(isbnsIndex)

byIndex = (isbnsIndex)-> (a, b)->
  isbnsIndex[a.normalizedIsbn].index - isbnsIndex[b.normalizedIsbn].index
