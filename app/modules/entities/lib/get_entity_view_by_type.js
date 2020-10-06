import EditionLayout from '../views/edition_layout'
import ClaimLayout from '../views/claim_layout'
import authorLayout from '../views/author_layout'
import serieLayout from '../views/serie_layout'
import workLayout from '../views/work_layout'
import publisherLayout from '../views/publisher_layout'
import articleLi from '../views/article_li'
import collectionLayout from '../views/collection_layout'

const entityViewByType = {
  human: authorLayout,
  serie: serieLayout,
  work: workLayout,
  publisher: publisherLayout,
  article: articleLi,
  collection: collectionLayout,
}
const standalone = true

export default async function getEntityViewByType (model, refresh) {
  const { type } = model
  const displayMergeSuggestions = app.user.hasDataadminAccess

  const getter = entityViewSpecialGetterByType[type]
  if (getter != null) return getter(model, refresh)

  const View = entityViewByType[type]
  if (View != null) {
    return new View({ model, refresh, standalone, displayMergeSuggestions })
  }

  let { defaultClaimProperty: property } = model
  const value = model.get('uri')
  if (!property) property = 'wdt:P921'
  return new ClaimLayout({ property, value, refresh })
}

const getEditionView = async (model, refresh) => {
  await model.waitForWorks
  return new EditionLayout({ model, refresh, standalone })
}

const entityViewSpecialGetterByType = { edition: getEditionView }
