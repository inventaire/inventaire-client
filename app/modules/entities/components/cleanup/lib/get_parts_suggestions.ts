import { uniq, property, pluck, flatten } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { getEntities, type SerializedEntity } from '#app/modules/entities/lib/entities'
import { searchWorks } from '#entities/lib/search/search_by_types'
import type { GetAuthorWorksResponse } from '#server/controllers/entities/get_entity_relatives'
import type { EntityUri } from '#server/types/entity'
import { addRelevanceScore, type WorkSuggestion } from './add_relevance_score.ts'

export async function getPartsSuggestions (serie: SerializedEntity, parts: SerializedEntity[], authorsUris: EntityUri[]) {
  const uris = await Promise.all([
    getAuthorsWorks(authorsUris),
    searchMatchWorks(serie, parts),
  ])
  .then(flatten)
  .then(uniq)

  const works = await getEntities(uris, { refresh: true })

  const partsSuggestions = works
    // Confirm the type, as the search might have failed to unindex a serie that use
    // to be considered a work
    .filter(isWorkWithoutSerie)
    .map(addRelevanceScore(serie))
    .filter(work => work.authorMatch || work.labelMatch)
    .sort(byDescendingPertinanceScore)

  return partsSuggestions as WorkSuggestion[]
}

function byDescendingPertinanceScore (a: WorkSuggestion, b: WorkSuggestion) {
  return b.pertinanceScore - a.pertinanceScore
}

async function getAuthorsWorks (authorsUris: EntityUri[]) {
  const authorsWorks = await Promise.all(authorsUris.map(fetchAuthorWorks))
  const authorsWorksUris = authorsWorks.map(works => pluck(works.filter(hasNoSerie), 'uri'))
  return authorsWorksUris.flat()
}

async function fetchAuthorWorks (authorUri: EntityUri) {
  const { works } = (await preq.get(API.entities.authorWorks(authorUri))) as GetAuthorWorksResponse
  return works
}

const hasNoSerie = work => work.serie == null

function isWorkWithoutSerie (entity: SerializedEntity) {
  return (entity.type === 'work') && (entity.claims['wdt:P179'] == null)
}

async function searchMatchWorks (serie: SerializedEntity, parts: SerializedEntity[]) {
  const { label: serieLabel } = serie
  const partsUris = new Set(pluck(parts, 'uri'))
  const { results } = await searchWorks({ search: serieLabel, limit: 20 })
  return results
  .filter(result => (result._score > 0.5) && !partsUris.has(result.uri))
  .map(property('uri'))
}
