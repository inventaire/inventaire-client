import type { getIsbnData } from '#inventory/lib/importer/extract_isbns'
import type { Isbn } from '#server/types/entity'

interface BaseCandidate {
  authors?: any
  details?: review
  editionTitle?: string
  goodReadsEditionId?: string
  isbnData?: ReturnType<typeof getIsbnData>
  index?: string
  libraryThingWorkId?: string
  notes?: string
  numberOfPages?: number
  publicationDate?: string
  rawEntry?: any
  shelvesNames?: string[]
}

export interface ExternalEntry extends BaseCandidate {
  error?: any
  isbn?: Isbn
  isbnData?: ReturnType<typeof getIsbnData>
}

export interface Candidate extends BaseCandidate {
  waitingForItemsCount?: any
}
