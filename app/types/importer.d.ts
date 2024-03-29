import type { IsbnData } from '#server/types/common'
import type { Isbn } from '#server/types/entity'

interface BaseCandidate {
  authors?: any
  details?: review
  editionTitle?: string
  goodReadsEditionId?: string
  isbnData?: IsbnData
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
}

export interface Candidate extends BaseCandidate {
  waitingForItemsCount?: any
}
