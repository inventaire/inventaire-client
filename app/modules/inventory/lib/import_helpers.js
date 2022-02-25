import getBestLangValue from '#entities/lib/get_best_lang_value'
import getOriginalLang from '#entities/lib/get_original_lang'
import { isNonEmptyString, isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'

export const createCandidate = (externalEntry, entitiesRes) => {
  const {
    index,
    isbnData,
    workTitle,
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
  if (isNonEmptyString(workTitle)) candidate.workTitle = workTitle
  if (authorsNames) candidate.authorsNames = authorsNames
  if (isNonEmptyString(details)) candidate.details = details
  if (isNonEmptyString(notes)) candidate.notes = notes
  if (isNonEmptyString(publicationDate)) candidate.publicationDate = publicationDate
  if (numberOfPages) candidate.numberOfPages = numberOfPages
  if (goodReadsEditionId) candidate.goodReadsEditionId = goodReadsEditionId
  if (libraryThingWorkId) candidate.libraryThingWorkId = libraryThingWorkId

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
  const candidatesIsbns = getNormalizedIsbns(candidates)
  return externalEntriesIsbns.every(isCandidateIsbn(candidatesIsbns))
}

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

export const resolveEntryAndFetchEntities = async externalEntry => {
  // take advantage of the file upload to update existing entities ASAP
  // but do not create to let user verify unresolved entries information
  const entry = serializeResolverEntry(externalEntry)
  const { entries } = await preq.post(app.API.entities.resolve, {
    entries: [ entry ],
    update: true
  })

  const uris = []
  const { edition, works, authors } = entries[0]
  const pushUri = subEntry => { if (subEntry.uri) uris.push(subEntry.uri) }
  pushUri(edition)
  works.forEach(pushUri)
  authors.forEach(pushUri)
  if (!isNonEmptyArray(uris)) return

  return preq.get(app.API.entities.getByUris(uris, false, editionRelatives))
}

const editionRelatives = [ 'wdt:P629', 'wdt:P50' ]

export const serializeResolverEntry = data => {
  const { isbn, workTitle: title, lang, authorsNames, normalizedIsbn } = data
  const labelLang = lang || app.user.lang

  const edition = {
    isbn: isbn || normalizedIsbn,
    claims: {
      'wdt:P1476': [ title ]
    }
  }

  const work = { labels: {}, claims: {} }
  work.labels[labelLang] = title

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
