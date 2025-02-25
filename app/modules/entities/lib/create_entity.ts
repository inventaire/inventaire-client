import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import type { EntityDraft } from '#app/types/entity'
import { serializeEntity } from './entities'

export type EntityDraftWithCreationParams = EntityDraft & { createOnWikidata?: boolean }

export async function createEntity (params: EntityDraftWithCreationParams) {
  const { labels, claims, createOnWikidata } = params
  const prefix = createOnWikidata === true ? 'wd' : 'inv'
  const entity = await preq.post(API.entities.create, { prefix, labels, claims })
  return serializeEntity(entity)
}
