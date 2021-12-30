import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'

export const createCandidate = (preCandidate, entitiesObj) => {
  const candidate = {}
  candidate.preCandidate = preCandidate

  const entities = Object.values(entitiesObj).map(serializeEntity)
  const { edition: editions, work: works, human: authors } = _.groupBy(entities, _.property('type'))
  if (!editions || editions.length > 1) {
    candidate.notFound = true
    return candidate
  }
  candidate.edition = editions[0]
  candidate.works = works
  candidate.authors = authors
  return candidate
}

export const preCandidateUri = preCandidate => {
  const isbn = preCandidate.isbnData?.normalizedIsbn
  if (isbn) return `isbn:${isbn}`
}

const serializeEntity = entity => {
  entity.originalLang = getOriginalLang(entity.claims)
  entity.label = getBestLangValue(app.user.lang, entity.originalLang, entity.labels).value
  entity.description = getBestLangValue(app.user.lang, entity.originalLang, entity.descriptions).value
  entity.pathname = `/entity/${entity.uri}`
  const [ prefix, id ] = entity.uri.split(':')
  entity.prefix = prefix
  entity.id = id
  return entity
}
