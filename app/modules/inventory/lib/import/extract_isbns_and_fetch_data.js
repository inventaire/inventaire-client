import fetchEntitiesSequentially from './fetch_entities_sequentially'
import extractIsbns from './extract_isbns'
import getCandidatesFromEntitiesDocs from './get_candidates_from_entities_docs'
const isbn2 = require('lib/get_assets')('isbn2')

export default text => isbn2.get()
.then(() => {
  // window.ISBN should now be initalized
  const isbnsData = extractIsbns(text)

  if (isbnsData.length === 0) { return [] }

  return fetchEntitiesSequentially(isbnsData)
  .then(parseResults)
})

var parseResults = function (data) {
  const { results, isbnsIndex } = data
  const newCandidates = getCandidatesFromEntitiesDocs(results.entities, isbnsIndex)

  return newCandidates
    .concat(results.notFound, results.invalidIsbn)
    // Make sure to display candidates in the order they where input
    // to help the user fill the missing information
    .sort(byIndex(isbnsIndex))
}

var byIndex = isbnsIndex => (a, b) => isbnsIndex[a.normalizedIsbn].index - isbnsIndex[b.normalizedIsbn].index
