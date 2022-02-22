import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'
import { isNonEmptyString } from '#lib/boolean_tests'

export const createCandidate = (preCandidate, entitiesRes) => {
  const { index, isbnData, customWorkTitle, customAuthorsNames, details, notes } = preCandidate
  const candidate = { index }
  if (isbnData && isbnData.normalizedIsbn.length === 10) {
    const redirectsUri = entitiesRes.redirects[guessUriFromIsbn({ preCandidate })]
    if (redirectsUri) isbnData.normalizedIsbn = redirectsUri.replace(/isbn:/, '')
  }
  if (isbnData) candidate.isbnData = isbnData
  if (isNonEmptyString(customWorkTitle)) candidate.customWorkTitle = customWorkTitle
  if (customAuthorsNames) candidate.customAuthorsNames = customAuthorsNames
  if (details) candidate.details = details
  if (notes) candidate.notes = notes

  if (!entitiesRes) return candidate
  const entities = Object.values(entitiesRes.entities).map(serializeEntity)
  const { edition: editions, work: works, human: authors } = _.groupBy(entities, _.property('type'))
  if (editions) candidate.edition = getEdition(editions)
  if (!candidate.edition) {
    candidate.notFound = true
    return candidate
  }
  candidate.works = works
  candidate.authors = authors || []
  return candidate
}

export const guessUriFromIsbn = ({ preCandidate, isbnData }) => {
  let isbn
  if (preCandidate) isbn = preCandidate.isbnData?.normalizedIsbn
  if (isbnData) isbn = isbnData.normalizedIsbn
  if (isbn) return `isbn:${isbn}`
}

const serializeEntity = entity => {
  entity.originalLang = getOriginalLang(entity.claims)
  entity.label = getBestLangValue(app.user.lang, entity.originalLang, entity.labels).value
  entity.pathname = `/entity/${entity.uri}`
  return entity
}

const getEdition = editions => {
  let edition
  if (editions && editions.length > 1) {
    // remove wikidata editions (see server issue #182)
    const invEditions = editions.filter(edition => !edition.uri.startsWith('wd:'))
    if (invEditions.length > 0) edition = invEditions[0]
  } else if (editions.length === 1) {
    edition = editions[0]
  }
  return edition
}

export const noNewCandidates = ({ preCandidates, candidates }) => {
  const preCandidatesIsbns = getNormalizedIsbns(preCandidates)
  const candidatesIsbns = getNormalizedIsbns(candidates)
  return preCandidatesIsbns.every(isCandidateIsbn(candidatesIsbns))
}

const getNormalizedIsbns = candidates => {
  return _.compact(candidates.map(candidate => candidate.isbnData?.normalizedIsbn))
}

export const isCandidateIsbn = candidatesIsbns => preCandidateIsbn => candidatesIsbns.includes(preCandidateIsbn)

export const byIndex = (a, b) => a.index - b.index

export const isAlreadyCandidate = (normalizedIsbn, candidates) => candidates.some(haveIsbn(normalizedIsbn))

const haveIsbn = isbn => candidate => candidate.isbnData?.normalizedIsbn === isbn

export const addExistingItemsCountToCandidate = counts => candidate => {
  const { isbnData } = candidate
  const uri = guessUriFromIsbn({ isbnData })
  if (uri == null) return candidate
  const count = counts[uri]
  if (count != null) candidate.existingItemsCount = count
  return candidate
}
