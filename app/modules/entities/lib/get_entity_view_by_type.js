import error_ from '#lib/error'
import { getEntitiesByUris } from '#entities/lib/entities'
const standalone = true

export default async function getEntityViewByType (model, refresh) {
  const entity = model.toJSON()
  const { type } = model
  const displayMergeSuggestions = app.user.hasDataadminAccess
  let props = { entity, standalone }

  const getter = entityViewSpecialGetterByType[type]
  if (getter != null) return getter(entity, refresh)

  let View, Component
  if (type === 'human') {
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
    const property = model.defaultClaimProperty || 'wdt:P921'
    props = { entity, property }
  }

  if (Component != null) {
    return {
      Component,
      props
    }
  }

  if (View != null) {
    const view = new View({ model, refresh, standalone, displayMergeSuggestions })
    return { view }
  }
}

const getEditionComponent = async (entity, refresh) => {
  const [ { default: EditionLayout }, works ] = await Promise.all([
    import('#entities/components/layouts/edition.svelte'),
    getEditionsWorks([ entity ], refresh)
  ])
  return {
    Component: EditionLayout,
    props: {
      entity,
      works,
      standalone
    }
  }
}

export const getEditionsWorks = async (editions, refresh) => {
  const uris = editions.map(getEditionWorksUris).flat()
  return getEntitiesByUris({ uris })
}

const getEditionWorksUris = edition => {
  const editionWorksUris = edition.claims['wdt:P629']
  if (edition.type !== 'edition') return []
  if (editionWorksUris == null) {
    const { uri } = edition
    const err = error_.new('edition entity misses associated works (wdt:P629)', { uri })
    throw err
  }
  return editionWorksUris
}

const entityViewSpecialGetterByType = {
  edition: getEditionComponent
}
