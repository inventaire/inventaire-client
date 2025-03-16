import { getLocalStorageStore } from '#app/lib/components/stores/local_storage_stores'
import type { RelativeUrl } from '#server/types/common'
import type { EntityUri, ExtendedEntityType } from '#server/types/entity'

export const searchResultsHistory = getLocalStorageStore('searches', [])

export interface HistoryEntry {
  uri: EntityUri
  label: string
  type: ExtendedEntityType
  pictures: RelativeUrl[]
  timestamp: EpochTimeStamp
}

export function resortSearchResultsHistory (history) {
  return history.sort((a, b) => b.timestamp - a.timestamp)
}

export function clearSearchHistory () {
  searchResultsHistory.set([])
}
