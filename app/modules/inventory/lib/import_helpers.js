import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'
import { createEntitiesByCandidate } from '#inventory/components/importer/create_candidate_entities'
import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'

export const createCandidate = (externalEntry, entitiesRes) => {
  const {
    index,
    isbnData,
    editionTitle,
    authorsNames,
    details,
    notes,
    publicationDate,
    numberOfPages,
    goodReadsEditionId,
    libraryThingWorkId
  } = externalEntry

  const candidate = { index }
  if (isbnData) candidate.isbnData = isbnData
  if (isNonEmptyString(editionTitle)) candidate.editionTitle = editionTitle
  if (authorsNames) candidate.authorsNames = authorsNames
  if (isNonEmptyString(details)) candidate.details = details
  if (isNonEmptyString(notes)) candidate.notes = notes
  if (isNonEmptyString(publicationDate)) candidate.publicationDate = publicationDate
  if (numberOfPages) candidate.numberOfPages = numberOfPages
  if (goodReadsEditionId) candidate.goodReadsEditionId = goodReadsEditionId
  if (libraryThingWorkId) candidate.libraryThingWorkId = libraryThingWorkId

  if (!entitiesRes) return candidate
  return assignEntitiesToCandidate(candidate, entitiesRes)
}

export const assignEntitiesToCandidate = (candidate, entitiesRes) => {
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

export const guessUriFromIsbn = ({ externalEntry, isbnData }) => {
  let isbn
  if (externalEntry) isbn = externalEntry.isbnData?.normalizedIsbn
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

export const noNewCandidates = ({ externalEntries, candidates }) => {
  const externalEntriesIsbns = getNormalizedIsbns(externalEntries)
  if (someWithoutIsbns) return false
  const candidatesIsbns = getNormalizedIsbns(candidates)
  return externalEntriesIsbns.every(isCandidateIsbn(candidatesIsbns))
}

const someWithoutIsbns = (externalEntries, externalEntriesIsbns) => externalEntriesIsbns.length !== externalEntries.length

const getNormalizedIsbns = candidates => {
  return _.compact(candidates.map(candidate => candidate.isbnData?.normalizedIsbn))
}

export const isCandidateIsbn = candidatesIsbns => externalEntryIsbn => candidatesIsbns.includes(externalEntryIsbn)

export const byIndex = (a, b) => a.index - b.index

export const isAlreadyCandidate = (normalizedIsbn, candidates) => candidates.some(haveIsbn(normalizedIsbn))

export const formatCandidatesData = isbns => isbns.map(isbn => ({ isbn }))

const haveIsbn = isbn => candidate => candidate.isbnData?.normalizedIsbn === isbn

export const addExistingItemsCountToCandidate = counts => candidate => {
  const { isbnData } = candidate
  const uri = guessUriFromIsbn({ isbnData })
  if (uri == null) return candidate
  const count = counts[uri]
  if (count != null) candidate.existingItemsCount = count
  return candidate
}

const areAllEntitiesResolved = candidate => candidate.edition && candidate.works

export const resolveAndCreateCandidateEntities = async candidate => {
  const { editionTitle, checked } = candidate
  if (!editionTitle || !checked || areAllEntitiesResolved(candidate)) return candidate
  let entitiesRes
  if (canBeResolved(candidate)) {
    const resolveOptions = { create: true }
    const resEntry = await resolveCandidate(candidate, resolveOptions)
    entitiesRes = await fetchAllMissingEntities(resEntry, editionRelatives)
    return assignEntitiesToCandidate(candidate, entitiesRes)
  } else {
    return createEntitiesByCandidate(candidate)
  }
}

const canBeResolved = candidate => {
  const { goodReadsEditionId } = candidate
  const isbn = findIsbn(candidate)
  return isbn || goodReadsEditionId
}

export const resolveCandidate = async (candidate, resolveOptions) => {
  const entry = serializeResolverEntry(candidate)
  const params = Object.assign({}, { entries: [ entry ] }, resolveOptions)
  const { entries } = await preq.post(app.API.entities.resolve, params)
  return entries[0]
}

export const getRelevantEntities = async (edition, works) => {
  if (edition?.uri) {
    // ignore resolver response, as some resolved uris might not be in the edition entity graph
    return preq.get(app.API.entities.getByUris(edition.uri, false, editionRelatives))
  } else {
    const worksUris = getUris(works)
    if (isNonEmptyArray(worksUris)) {
      // ignore authors to let user verify authors information
      return preq.get(app.API.entities.getByUris(worksUris, false, editionRelatives))
    }
  }
}

const editionRelatives = [ 'wdt:P629', 'wdt:P50' ]

const getUris = works => _.compact(works.map(getUri))

const getUri = _.property('uri')

const fetchAllMissingEntities = (resEntry, editionRelatives) => {
  const uris = []
  const { edition, works, authors } = resEntry
  const pushUri = subEntry => { if (subEntry.uri) uris.push(subEntry.uri) }
  pushUri(edition)
  works.forEach(pushUri)
  authors.forEach(pushUri)
  if (!isNonEmptyArray(uris)) return
  return preq.get(app.API.entities.getByUris(uris, false, editionRelatives))
}

const findIsbn = data => {
  const { isbn, normalizedIsbn, isbnData } = data
  return isbn || normalizedIsbn || isbnData?.normalizedIsbn
}

const serializeResolverEntry = data => {
  const { editionTitle, lang, authorsNames } = data
  let { isbn } = data
  const labelLang = lang || app.user.lang

  const edition = {
    claims: {
      'wdt:P1476': [ editionTitle ]
    }
  }

  isbn = findIsbn(data)
  if (isbn) Object.assign(edition, { isbn })

  const work = { labels: {}, claims: {} }
  work.labels[labelLang] = editionTitle

  if (data.publicationDate != null) edition.claims['wdt:P577'] = data.publicationDate
  if (data.numberOfPages != null) edition.claims['wdt:P1104'] = data.numberOfPages
  if (data.goodReadsEditionId != null) edition.claims['wdt:P2969'] = data.goodReadsEditionId
  if (data.libraryThingWorkId != null) work.claims['wdt:P1085'] = data.libraryThingWorkId

  let authors

  if (authorsNames) {
    authors = authorsNames.map(name => {
      const labels = { [labelLang]: name }
      return { labels }
    })
  }

  return { edition, works: [ work ], authors }
}

export const getEditionEntitiesByUri = async isbn => {
  const editionUri = `isbn:${isbn}`
  return preq.get(app.API.entities.getByUris(editionUri, false, editionRelatives))
}
