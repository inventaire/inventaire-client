import error_ from '#lib/error'
import preq from '#lib/preq'
import { serializeEntity } from '#entities/lib/entities'
import { aliasRedirects } from '#entities/lib/entities_models_index'
const standalone = true

export default async function getEntityViewByType (model, refresh) {
  const entity = model.toJSON()
  const { type } = model
  const displayMergeSuggestions = app.user.hasDataadminAccess

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
    ({ default: View } = await import('../views/article_li'))
  }

  if (Component != null) {
    return {
      Component,
      props: {
        entity,
        standalone
      }
    }
  }
  if (View != null) {
    const view = new View({ model, refresh, standalone, displayMergeSuggestions })
    return { view }
  }

  let { defaultClaimProperty: property } = model
  const value = model.get('uri')
  if (!property) property = 'wdt:P921'
  const { default: ClaimLayout } = await import('../views/claim_layout')
  const view = new ClaimLayout({ property, value, refresh })
  return { view }
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
  const worksUris = editions.map(getEditionWorksUris).flat()
  if (worksUris.length === 0) return []
  const { entities, redirects } = await preq.get(app.API.entities.getByUris(worksUris, refresh))
  aliasRedirects(entities, redirects)
  // Filtering-out any non-work undetected by the SPARQL query
  return Object.values(entities)
  .filter(entity => entity.type === 'work')
  .map(serializeEntity)
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
