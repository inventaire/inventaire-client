import { uniqueId } from 'underscore'
import app from '#app/app'
import getEntitiesItemsCount from '#inventory/lib/get_entities_items_count'
import { getIsbnData } from '#inventory/lib/importer/extract_isbns'
import { addExistingItemsCountToCandidate, getEditionEntitiesByUri, getRelevantEntities, guessUriFromIsbn, resolveCandidate } from '#inventory/lib/importer/import_helpers'
import error_ from '#lib/error'
import log_ from '#lib/loggers'

export const createExternalEntry = candidateData => {
  const { isbn, title, authors = [] } = candidateData
  const externalEntry = {
    index: uniqueId('candidate'),
    editionTitle: title,
    authors: authors.map(name => ({ label: name })),
  }
  delete candidateData.title
  delete candidateData.authors
  Object.assign(externalEntry, candidateData)
  if (isbn) externalEntry.isbnData = getIsbnData(isbn)
  if (externalEntry.isbnData?.isInvalid) {
    externalEntry.error = new Error('invalid isbn')
    delete externalEntry.isbnData
    delete externalEntry.isbn
  }
  return externalEntry
}

export const addExistingItemsCounts = async function ({ candidates, externalEntries }) {
  const uris = _.compact(externalEntries.map(getExternalEntryUri))
  const waitingForItemsCounts = getEntitiesItemsCount(app.user.id, uris)
  candidates.forEach(candidate => { candidate.waitingForItemsCount = waitingForItemsCounts })
  const counts = await waitingForItemsCounts
  candidates.forEach(addExistingItemsCountToCandidate(counts))
}

const getExternalEntryUri = externalEntry => guessUriFromIsbn({ externalEntry })

export const getExternalEntriesEntities = async externalEntry => {
  try {
    if (externalEntry.editionTitle) {
      const resolveOptions = { update: true }
      const resEntry = await resolveCandidate(externalEntry, resolveOptions)
      const { edition, works } = resEntry
      return getRelevantEntities(edition, works)
    } else if (externalEntry.isbnData) {
      // Not enough data for the resolver, so get edition by uri directly
      const { normalizedIsbn } = externalEntry.isbnData
      return getEditionEntitiesByUri(normalizedIsbn)
    } else {
      throw error_.new('not enough entry data', 400, { externalEntry })
    }
  } catch (err) {
    log_.error(err, 'no entities found err')
  }
}
