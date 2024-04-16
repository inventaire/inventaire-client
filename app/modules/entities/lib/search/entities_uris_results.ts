import SearchResult from '#entities/models/search_result'
const wdIdPattern = /Q\d+/
const invIdPattern = /[0-9a-f]{32}/

export const getEntityUri = input => {
  // Match ids instead of URIs to be very tolerent on the possible inputs
  const wdId = input.match(wdIdPattern)?.[0]
  if (wdId != null) return `wd:${wdId}`
  const invId = input.match(invIdPattern)?.[0]
  if (invId != null) return `inv:${invId}`
}

const getEntityId = input => getEntityUri(input)?.split(':')[1]

export const prepareSearchResult = model => {
  const [ , id ] = model.get('uri').split(':')
  const data = model.pick([ 'uri', 'label', 'labels', 'aliases', 'descriptions' ])
  data.id = id
  const searchResult = new SearchResult(data)
  searchResult.fieldMatch = customFieldMatch
  return searchResult
}

// Let a full URL like
// http://localhost:3006/entity/inv:1d622035ca5515d12800e23e7f00c3eb
// match
// 1d622035ca5515d12800e23e7f00c3eb
const customFieldMatch = (filterRegex, rawInput) => field => {
  if (field == null) return false
  const entityId = getEntityId(rawInput)
  const fieldContainsInput = (field.match(filterRegex) != null)
  const inputContainsEntityId = (entityId != null) && (rawInput.match(entityId) != null)
  return fieldContainsInput || inputContainsEntityId
}
