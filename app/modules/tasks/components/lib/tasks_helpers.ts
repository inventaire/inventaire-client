import { intersection, pluck } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { getSerieOrWorkExtendedAuthorsUris } from '#app/modules/entities/lib/types/serie_alt'
import { getSubEntities, fetchSectionEntities } from '#entities/components/lib/entities'
import type { SerializedEntity } from '#entities/lib/entities'
import { I18n } from '#user/lib/i18n'

export const calculateGlobalScore = task => {
  const { externalSourcesOccurrences, lexicalScore, relationScore } = task
  let score = 0
  const externalSourcesOccurrencesCount = externalSourcesOccurrences.length
  if (externalSourcesOccurrencesCount) score += 80 * externalSourcesOccurrencesCount
  if (lexicalScore) score += lexicalScore
  if (relationScore) score += relationScore * 10
  return Math.trunc(score * 100) / 100
}

export function sortMatchedLabelsEntities (entities, matchedTitles) {
  return entities.sort((a, b) => hasMatchedLabel(a, matchedTitles) < hasMatchedLabel(b, matchedTitles) ? 1 : -1)
}

export function hasMatchedLabel (entity, matchedTitles) {
  const entityLabels = Object.values(entity.labels)
  const matchedLabels = intersection(matchedTitles, entityLabels)
  return matchedLabels.length > 0
}

const urisGetterByType = {
  human: async ({ entity }) => {
    const { uri: parentUri } = entity
    const { series, works, articles } = await preq.get(API.entities.authorWorks(parentUri))
    return [
      {
        label: I18n('series'),
        uris: pluck(series, 'uri'),
      },
      {
        label: I18n('works'),
        uris: pluck(works, 'uri'),
      },
      {
        label: I18n('articles'),
        uris: pluck(articles,
          'uri'),
      },
    ]
  },
  work: async ({ entity }) => {
    const authorUris = getSerieOrWorkExtendedAuthorsUris(entity)
    const editions = await getSubEntities('work', entity.uri)
    return [
      {
        label: I18n('authors'),
        uris: authorUris,
      },
      {
        label: I18n('editions'),
        uris: pluck(editions, 'uri'),
        entities: editions,
      },
    ]
  },
  collection: async ({ entity }) => {
    const publisherUris = entity.claims['wdt:P123']
    return [
      {
        label: I18n('publishers'),
        uris: publisherUris,
      },
    ]
  },
  publisher: async ({ entity }) => {
    const { uri: parentUri } = entity
    const { collections, editions } = await preq.get(API.entities.publisherPublications(parentUri))
    return [
      {
        label: I18n('collections'),
        uris: pluck(collections, 'uri'),
      },
      {
        label: I18n('editions'),
        uris: pluck(editions, 'uri'),
      },
    ]
  },
}

export async function getRelatedEntitiesSections ({ entity }: { entity: SerializedEntity }) {
  const { type } = entity
  const getRelatedEntitiesUris = urisGetterByType[type]
  const sections = await getRelatedEntitiesUris({ entity })
  await Promise.all(sections.map(fetchSectionEntities({ parentEntityType: type })))
  return sections
}
