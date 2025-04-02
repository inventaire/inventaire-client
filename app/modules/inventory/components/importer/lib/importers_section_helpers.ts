import { compact, uniqueId } from 'underscore'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import type { ExternalEntry, Candidate } from '#app/types/importer'
import getEntitiesItemsCount from '#inventory/lib/get_entities_items_count'
import { getIsbnData } from '#inventory/lib/importer/extract_isbns'
import { addExistingItemsCountToCandidate, getEditionEntitiesByUri, getRelevantEntities, guessUriFromIsbn, resolveCandidate } from '#inventory/lib/importer/import_helpers'
import { mainUser } from '#user/lib/main_user'

export const createExternalEntry = candidateData => {
  const { isbn, title, authors = [] } = candidateData
  const externalEntry: ExternalEntry = {
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

export const addExistingItemsCounts = async function ({ candidates, externalEntries }: { candidates: Candidate[], externalEntries: ExternalEntry[] }) {
  const uris = compact(externalEntries.map(getExternalEntryUri))
  const waitingForItemsCounts = getEntitiesItemsCount(mainUser._id, uris)
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
      throw newError('not enough entry data', 400, { externalEntry })
    }
  } catch (err) {
    log_.error(err, 'no entities found err')
  }
}
