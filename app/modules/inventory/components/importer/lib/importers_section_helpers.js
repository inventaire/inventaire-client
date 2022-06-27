import app from '#app/app'
import { uniqueId } from 'underscore'
import isbnExtractor from '#inventory/lib/importer/extract_isbns'
import { addExistingItemsCountToCandidate, getEditionEntitiesByUri, getRelevantEntities, guessUriFromIsbn, resolveCandidate } from '#inventory/lib/importer/import_helpers'

export const createExternalEntry = candidateData => {
  const { isbn, title, authors = [] } = candidateData
  let externalEntry = {
    index: uniqueId('candidate'),
    editionTitle: title,
    authors: authors.map(name => ({ label: name })),
  }
  delete candidateData.title
  delete candidateData.authors
  Object.assign(externalEntry, candidateData)
  if (isbn) externalEntry.isbnData = isbnExtractor.getIsbnData(isbn)
  if (externalEntry.isbnData?.isInvalid) return
  return externalEntry
}

export const addExistingItemsCounts = async function ({ candidates, externalEntries }) {
  const uris = _.compact(externalEntries.map(getExternalEntryUri))
  const counts = await app.request('items:getEntitiesItemsCount', app.user.id, uris)
  candidates.forEach(addExistingItemsCountToCandidate(counts))
}

const getExternalEntryUri = externalEntry => guessUriFromIsbn({ externalEntry })

export const getExternalEntriesEntities = async externalEntry => {
  try {
    if (!externalEntry.editionTitle) {
      const { normalizedIsbn } = externalEntry.isbnData
      // not enough data for the resolver, so get edition by uri directly
      return getEditionEntitiesByUri(normalizedIsbn)
    } else {
      const resolveOptions = { update: true }
      const resEntry = await resolveCandidate(externalEntry, resolveOptions)
      const { edition, works } = resEntry
      return getRelevantEntities(edition, works)
    }
  } catch (err) {
    log_.error(err, 'no entities found err')
  }
}
