import { groupBy, property, compact } from 'underscore'
import app from '#app/app'
import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'
import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'
import type { ExternalEntry, Candidate } from '#types/importer'
import type { getIsbnData } from './extract_isbns'

export const createCandidate = (externalEntry, entitiesRes) => {
  const {
    index,
    isbnData,
    editionTitle,
    authors,
    details,
    notes,
    publicationDate,
    numberOfPages,
    goodReadsEditionId,
    libraryThingWorkId,
    shelvesNames,
    rawEntry,
  } = externalEntry

  const candidate: Candidate = { index, rawEntry }
  if (isbnData) candidate.isbnData = isbnData
  if (isNonEmptyString(editionTitle)) candidate.editionTitle = editionTitle
  if (authors) candidate.authors = authors
  if (isNonEmptyString(details)) candidate.details = details
  if (isNonEmptyString(notes)) candidate.notes = notes
  if (isNonEmptyString(publicationDate)) candidate.publicationDate = publicationDate
  if (numberOfPages) candidate.numberOfPages = numberOfPages
  if (goodReadsEditionId) candidate.goodReadsEditionId = goodReadsEditionId
  if (libraryThingWorkId) candidate.libraryThingWorkId = libraryThingWorkId
  if (shelvesNames) candidate.shelvesNames = shelvesNames

  if (!entitiesRes) return candidate
  return assignEntitiesToCandidate(candidate, entitiesRes)
}

export const assignEntitiesToCandidate = (candidate, entitiesRes) => {
  const entities = Object.values(entitiesRes.entities).map(serializeEntity)
  const { edition: editions, work: works, human: authors } = groupBy(entities, property('type'))
  if (editions) candidate.edition = getEdition(editions)
  // Works and authors might have been resolved independently from the edition
  candidate.works = works
  candidate.authors = authors || []
  if (!candidate.edition) {
    candidate.notFound = true
  }
  return candidate
}

export const guessUriFromIsbn = ({ externalEntry, isbnData }: { externalEntry?: ExternalEntry, isbnData?: ReturnType<typeof getIsbnData> }) => {
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

export const byIndex = (a, b) => a.index - b.index

export const formatCandidatesData = isbns => isbns.map(isbn => ({ isbn }))

export const addExistingItemsCountToCandidate = counts => candidate => {
  const { isbnData } = candidate
  const uri = guessUriFromIsbn({ isbnData })
  if (uri == null) return candidate
  const count = counts[uri]
  if (count != null) candidate.existingItemsCount = count
  return candidate
}

export const resolveAndCreateCandidateEntities = async candidate => {
  const resEntry = await resolveCandidate(candidate, { create: true })
  const entitiesRes = await fetchAllMissingEntities(resEntry, editionRelatives)
  return assignEntitiesToCandidate(candidate, entitiesRes)
}

export const isResolved = entity => entity.uri != null

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

const getUris = works => compact(works.map(getUri))

const getUri = property('uri')

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
  const { lang, rawEntry, works: resolvedWorks } = data
  // work as resolved by EntityResolverInput
  const resolvedWork = resolvedWorks[0]
  let { editionTitle, isbn, authors = [] } = data
  const labelLang = lang || app.user.lang

  if (resolvedWork && !editionTitle) {
    editionTitle = resolvedWork.label
  }

  const edition = {
    claims: {
      'wdt:P1476': [ editionTitle ],
    },
  }

  isbn = findIsbn(data)
  if (isbn) Object.assign(edition, { isbn })

  let work
  if (resolvedWork?.uri) {
    work = {
      uri: resolvedWork.uri,
    }
  } else {
    work = { labels: {}, claims: {} }
    work.labels[labelLang] = editionTitle
  }

  if (data.publicationDate != null) edition.claims['wdt:P577'] = data.publicationDate
  if (data.numberOfPages != null) edition.claims['wdt:P1104'] = data.numberOfPages
  if (data.goodReadsEditionId != null) edition.claims['wdt:P2969'] = data.goodReadsEditionId
  if (data.libraryThingWorkId != null) work.claims['wdt:P1085'] = data.libraryThingWorkId

  authors = authors.map(author => {
    const { uri, label } = author
    return {
      uri,
      labels: {
        [labelLang]: label,
      },
    }
  })

  return { edition, works: [ work ], authors, rawEntry }
}

export const getEditionEntitiesByUri = async isbn => {
  const editionUri = `isbn:${isbn}`
  return preq.get(app.API.entities.getByUris(editionUri, false, editionRelatives))
}
