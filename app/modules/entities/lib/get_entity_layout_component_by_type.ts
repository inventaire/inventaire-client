import { newError } from '#app/lib/error'
import { getEntities, type SerializedEntity } from '#entities/lib/entities'
import { defaultClaimPropertyByType } from '../models/entity'

export async function getEntityLayoutComponentByType (entity: SerializedEntity) {
  const { type } = entity

  let Component
  if (type === 'edition') {
    const [ { default: EditionLayout }, works ] = await Promise.all([
      import('#entities/components/layouts/edition.svelte'),
      getEditionsWorks([ entity ]),
    ])
    const props = { entity, works }
    return { Component: EditionLayout, props }
  } else if (type === 'human') {
    ({ default: Component } = await import('#entities/components/layouts/author.svelte'))
  } else if (type === 'serie') {
    ({ default: Component } = await import('#entities/components/layouts/serie.svelte'))
  } else if (type === 'work') {
    ({ default: Component } = await import('#entities/components/layouts/work.svelte'))
  } else if (type === 'publisher') {
    ({ default: Component } = await import('#entities/components/layouts/publisher.svelte'))
  } else if (type === 'collection') {
    ({ default: Component } = await import('#entities/components/layouts/collection.svelte'))
  } else if (type === 'article') {
    ({ default: Component } = await import('#entities/components/layouts/article.svelte'))
  } else {
    ({ default: Component } = await import('#entities/components/layouts/claim_layout.svelte'))
    const property = defaultClaimPropertyByType[type] || 'wdt:P921'
    return { Component, props: { entity, property } }
  }
  return { Component, props: { entity } }
}

export const getEditionsWorks = async editions => {
  const uris = editions.map(getEditionWorksUris).flat()
  return getEntities(uris)
}

const getEditionWorksUris = edition => {
  const editionWorksUris = edition.claims['wdt:P629']
  if (edition.type !== 'edition') return []
  if (editionWorksUris == null) {
    const { uri } = edition
    const err = newError('edition entity misses associated works (wdt:P629)', { uri })
    throw err
  }
  return editionWorksUris
}
