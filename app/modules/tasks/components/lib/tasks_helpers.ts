import { intersection, pluck, values } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { getSubEntities, fetchSectionEntities } from '#entities/components/lib/entities'
import { type SerializedEntity, getEditionsWorks } from '#entities/lib/entities'
import { getSerieOrWorkExtendedAuthorsUris } from '#entities/lib/types/serie_alt'
import { I18n, i18n } from '#user/lib/i18n'

export const calculateGlobalScore = task => {
  const { externalSourcesOccurrences, lexicalScore, relationScore } = task
  let score = 0
  const externalSourcesOccurrencesCount = externalSourcesOccurrences.length
  if (externalSourcesOccurrencesCount) score += 80 * externalSourcesOccurrencesCount
  if (lexicalScore) score += lexicalScore
  if (relationScore) score += relationScore * 10
  return Math.trunc(score * 100) / 100
}

export const entitiesTypesByTypes = {
  delete: [ 'human', 'work', 'edition', 'serie', 'publisher', 'collection' ],
  merge: [ 'human', 'work', 'edition', 'serie', 'publisher', 'collection' ],
  deduplicate: [ 'human', 'work' ],
}

export function sortMatchedLabelsEntities (entities, matchedTitles) {
  return entities.sort((a, b) => hasMatchedLabel(a, matchedTitles) < hasMatchedLabel(b, matchedTitles) ? 1 : -1)
}

export function hasMatchedLabel (entity, matchedTitles) {
  const entityLabels = Object.values(entity.labels)
  const matchedLabels = intersection(matchedTitles, entityLabels)
  return matchedLabels.length > 0
}

export async function updateTask (id, attribute, value) {
  const params = { id, attribute, value }
  return preq.put(API.tasks.update, params)
}

export function areRedirects (entities, redirects) {
  if (Object.keys(redirects).length === 0) return
  for (const entityUri of values(redirects)) {
    if (entities[entityUri]) return true
  }
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
  serie: async ({ entity }) => {
    const authorUris = getSerieOrWorkExtendedAuthorsUris(entity)
    const works = await getSubEntities('serie', entity.uri)
    return [
      {
        label: I18n('authors'),
        uris: authorUris,
      },
      {
        label: I18n('works'),
        uris: pluck(works, 'uri'),
        entities: works,
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
  edition: async ({ entity }) => {
    const works = await getEditionsWorks([ entity ])
    const publisherUris = entity.claims['wdt:P123']
    return [
      {
        label: I18n('publishers'),
        uris: publisherUris,
      },
      {
        label: I18n('works'),
        entities: works,
        uris: pluck(works, 'uri'),
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

export async function getTasksCounts () {
  const { tasksCount } = await preq.get(API.tasks.count)
  return tasksCount
}

export function getTaskMetadata (task?) {
  if (task) {
    return { metadata: { title: `${I18n('task')} - ${i18n(task.type)} - ${i18n(task.entitiesType)} - ${task._id}` } }
  } else {
    return { metadata: { title: I18n('no task available') } }
  }
}
