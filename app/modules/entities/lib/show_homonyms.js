import preq from '#lib/preq'
import Entities from '../collections/entities.js'
import getBestLangValue from './get_best_lang_value'
import { someMatch } from '#lib/utils'
import { getEntitiesByUris } from '#entities/lib/entities'

export default async params => {
  if (!app.user.hasDataadminAccess) return
  const { layout, regionName, model, standalone } = params

  const [ entities, { default: MergeHomonyms } ] = await Promise.all([
    getHomonyms(model),
    import('../views/editor/merge_homonyms')
  ])
  const collection = new Entities(entities)
  layout.showChildView(regionName, new MergeHomonyms({ collection, model, standalone }))
}

const getHomonyms = async model => {
  const [ uri, labels, aliases ] = model.gets('uri', 'labels', 'aliases')
  const terms = getSearchTermsSelection(labels, aliases)
  const { pluralizedType } = model
  const responses = await Promise.all(terms.map(searchTerm(pluralizedType)))
  const results = _.pluck(responses, 'results').flat()
  return parseSearchResults(uri, results)
}

const searchTerm = types => term => {
  return preq.get(app.API.search({
    types,
    search: term,
    limit: 100,
    exact: true
  }))
}

export const getHomonymsEntities = async entity => {
  const { uri, labels, aliases } = entity
  const terms = getSearchTermsSelection(labels, aliases)
  const pluralizedType = `${entity.type}s`
  const responses = await Promise.all(terms.map(searchTerm(pluralizedType)))
  const results = _.pluck(responses, 'results').flat()
  return parseSearchResultsToEntities(uri, results)
}

const parseSearchResults = async (uri, searchResults) => {
  const uris = _.uniq(_.pluck(searchResults, 'uri'))
    .filter(result => result.uri !== uri)
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await app.request('get:entities:models', { uris })
  return entities
  // Re-filter out uris to omit as a redirection might have brought it back
  .filter(entity => entity.get('uri') !== uri)
  .filter(entity => {
    const claims = entity.get('claims')
    return isntRelatedToAnyOtherEntity([ uri, ...uris ], claims)
  })
}

const parseSearchResultsToEntities = async (uri, searchResults) => {
  const uris = _.uniq(_.pluck(searchResults, 'uri'))
    .filter(result => result.uri !== uri)
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await getEntitiesByUris(uris)
  // Re-filter out uris to omit as a redirection might have brought it back
  return entities.filter(entity => entity.uri !== uri)
  .filter(entity => isntRelatedToAnyOtherEntity([ uri, ...uris ], entity.claims))
}

const isntRelatedToAnyOtherEntity = (uris, entityClaims) => {
  const relationClaims = _.pick(entityClaims, relationClaimsProperties)
  const relationClaimValues = Object.values(relationClaims).flat()
  return !someMatch(relationClaimValues, uris)
}

const relationClaimsProperties = [
  // All types
  'wdt:P138', // named after
  'wdt:P361', // part of
  'wdt:P2959', // permanent duplicated item
  // Works and series
  'wdt:P144', // based on
  'wdt:P155', // follows
  'wdt:P156', // is followed by
  'wdt:P179', // series
  'wdt:P921', // main subject
  'wdt:P941', // inspired by
  'wdt:P2860', // cites work
  // Publishers
  'wdt:P127', // owned by
]

const getSearchTermsSelection = (labels, aliases) => {
  let terms = getTerms(labels, aliases)
  if (terms.length > 10) {
    const { lang: bestAvailableLang } = getBestLangValue(app.user.lang, null, labels)
    const langsShortlist = _.uniq([ bestAvailableLang, 'en' ])
    labels = _.pick(labels, langsShortlist)
    aliases = _.pick(aliases, langsShortlist)
    return getTerms(labels, aliases).slice(0, 10)
  } else {
    return terms
  }
}

const getTerms = (labels, aliases) => {
  let terms = Object.values(labels)
    .concat(Object.values(aliases).flat())
    // Order term words to not search both "foo bar" and "bar foo"
    // as words order doesn't matter
    .map(orderTermWordsAlphabetically)
  return _.uniq(terms)
}

const orderTermWordsAlphabetically = term => {
  return term
  .toLowerCase()
  // Remove characters known to create duplicates
  .replace(/[.]/g, '')
  .split(' ')
  .sort((a, b) => a > b ? 1 : -1)
  .join(' ')
}
