const standalone = true

export default async function getEntityViewByType (model, refresh) {
  const { type } = model
  const displayMergeSuggestions = app.user.hasDataadminAccess

  const getter = entityViewSpecialGetterByType[type]
  if (getter != null) return getter(model, refresh)

  let View
  if (type === 'human') {
    ({ default: View } = await import('../views/author_layout'))
  } else if (type === 'serie') {
    ({ default: View } = await import('../views/serie_layout'))
  } else if (type === 'work') {
    ({ default: View } = await import('../views/work_layout'))
  } else if (type === 'publisher') {
    ({ default: View } = await import('../views/publisher_layout'))
  } else if (type === 'article') {
    ({ default: View } = await import('../views/article_li'))
  } else if (type === 'collection') {
    ({ default: View } = await import('../views/collection_layout'))
  }

  if (View != null) {
    return new View({ model, refresh, standalone, displayMergeSuggestions })
  }

  let { defaultClaimProperty: property } = model
  const value = model.get('uri')
  if (!property) property = 'wdt:P921'
  const { default: ClaimLayout } = await import('../views/claim_layout')
  return new ClaimLayout({ property, value, refresh })
}

const getEditionView = async (model, refresh) => {
  const [ { default: EditionLayout } ] = await Promise.all([
    import('../views/edition_layout'),
    model.waitForWorks
  ])
  return new EditionLayout({ model, refresh, standalone })
}

const entityViewSpecialGetterByType = {
  edition: getEditionView
}
