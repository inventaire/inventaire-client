import log_ from '#app/lib/loggers'
import type { TimeoutId } from '#app/types/common'
import type { EntityUri } from '#server/types/entity'

const refreshingEntities: Record<EntityUri, TimeoutId> = {}

export function startRefreshTimeSpan (uri: EntityUri) {
  log_.info(uri, 'start refresh time span')
  if (refreshingEntities[uri]) clearTimeout(refreshingEntities[uri])
  refreshingEntities[uri] = setTimeout(() => {
    log_.info(uri, 'stop refresh time span')
    delete refreshingEntities[uri]
  }, 2000)
}

export function entityDataShouldBeRefreshed (uri: EntityUri) {
  return refreshingEntities[uri] != null
}
