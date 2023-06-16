import preq from '#lib/preq'
import getBestLangValue from './get_best_lang_value'
import { someMatch } from '#lib/utils'
import { getEntitiesByUris } from '#entities/lib/entities'
import { partition, pick, pluck, uniq } from 'underscore'
import { pluralize } from '#entities/lib/types/entities_types'

export const getHomonymsEntities = async entity => {
  const { uri, labels, aliases, type } = entity
  const terms = getSearchTermsSelection(labels, aliases)
  const responses = await Promise.all(terms.map(searchTerm(type)))
  const results = pluck(responses, 'results').flat()
  return parseSearchResultsToEntities(uri, results)
}

const searchTerm = type => term => {
  return preq.get(app.API.search({
    types: pluralize(type),
    search: term,
    limit: 100,
    exact: true
  }))
}

const parseSearchResultsToEntities = async (uri, searchResults) => {
  const uris = uniq(pluck(searchResults, 'uri'))
    .filter(result => result.uri !== uri)
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await getEntitiesByUris(uris)
  // Re-filter out uris to omit as a redirection might have brought it back
  return entities
  .filter(entity => entity.uri !== uri)
  .filter(entity => isntRelatedToAnyOtherEntity([ uri, ...uris ], entity.claims))
}

const isntRelatedToAnyOtherEntity = (uris, entityClaims) => {
  const relationClaims = pick(entityClaims, relationClaimsProperties)
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
    const langsShortlist = uniq([ bestAvailableLang, 'en' ])
    labels = pick(labels, langsShortlist)
    aliases = pick(aliases, langsShortlist)
    terms = getTerms(labels, aliases)
    const [ multiWordsTerms ] = partition(terms, isMultiWordsTerm)
    if (multiWordsTerms.length > 0) terms = multiWordsTerms
    terms = terms.slice(0, 10)
  }
  return terms
}

const isMultiWordsTerm = term => getWordsCount(term) > 1
const getWordsCount = term => term.split(' ').length

const getTerms = (labels, aliases) => {
  let terms = Object.values(labels)
    .concat(Object.values(aliases).flat())
    // Order term words to not search both "foo bar" and "bar foo"
    // as words order doesn't matter
    .map(orderTermWordsAlphabetically)
  return uniq(terms)
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

export function haveLabelMatch (suggestion, targetEntity) {
  return someMatch(getNormalizedLabels(suggestion), getNormalizedLabels(targetEntity))
}

const getNormalizedLabels = entity => {
  if (!entity._normalizedLabels) {
    const normalizedLabels = Object.values(entity.labels)
      .map(normalizeLabel)
      .filter(term => term.trim().length > 0)
      .map(orderTermWordsAlphabetically)
    entity._normalizedLabels = uniq(normalizedLabels)
  }
  return entity._normalizedLabels
}

const normalizeLabel = label => {
  return label.toLowerCase()
  // Replace any non-letter non-number (from any script, not just ascii as \W would do) with a space
  // See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Regular_expressions/Unicode_character_class_escape
  // and https://javascript.info/regexp-unicode#unicode-properties-p
  .replace(/\P{Alphabetic}+/ug, ' ')
  .replace(/\s+/g, ' ')
  .trim()
}
