import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'
import { forceArray } from '#lib/utils'

export const serializeResolverEntry = candidate => {
  const { lang, isbn, isbnData, title, authors: authorsNames } = candidate
  const labelLang = lang || app.user.lang

  const edition = {
    isbn: isbn || isbnData?.normalizedIsbn,
  }
  if (!edition.isbn) return
  if (title) {
    edition.claims = {
      'wdt:P1476': [ title ]
    }
  }

  const work = { labels: {}, claims: {} }
  work.labels[labelLang] = title

  if (candidate.publicationDate != null) edition.claims['wdt:P577'] = candidate.publicationDate
  if (candidate.numberOfPages != null) edition.claims['wdt:P1104'] = candidate.numberOfPages
  if (candidate.goodReadsEditionId != null) edition.claims['wdt:P2969'] = candidate.goodReadsEditionId
  if (candidate.libraryThingWorkId != null) work.claims['wdt:P1085'] = candidate.libraryThingWorkId

  const authors = forceArray(authorsNames).map(name => {
    const labels = { [labelLang]: name }
    return { labels }
  })

  return { edition, works: [ work ], authors }
}

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
