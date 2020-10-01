import EditionLayout from '../views/edition_layout'
import ClaimLayout from '../views/claim_layout'

const entityViewByType = {
  human: require('../views/author_layout'),
  serie: require('../views/serie_layout'),
  work: require('../views/work_layout'),
  publisher: require('../views/publisher_layout'),
  article: require('../views/article_li'),
  collection: require('../views/collection_layout')
}
const standalone = true

const getEntityViewByType = function (model, refresh) {
  const { type } = model
  const displayMergeSuggestions = app.user.hasDataadminAccess

  const getter = entityViewSpecialGetterByType[type]
  if (getter != null) { return getter(model, refresh) }

  const View = entityViewByType[type]
  if (View != null) { return new View({ model, refresh, standalone, displayMergeSuggestions }) }

  let { defaultClaimProperty: property } = model
  const value = model.get('uri')
  if (!property) { property = 'wdt:P921' }
  return new ClaimLayout({ property, value, refresh })
}

const getEditionView = (model, refresh) => model.waitForWorks
.then(() => new EditionLayout({ model, refresh, standalone }))

const entityViewSpecialGetterByType =
  { edition: getEditionView }

export default (...args) => Promise.try(getEntityViewByType.bind(null, ...Array.from(args)))
