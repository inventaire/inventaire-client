entityViewByType =
  human: require '../views/author_layout'
  serie: require '../views/serie_layout'
  work: require '../views/work_layout'
  publisher: require '../views/publisher_layout'
  article: require '../views/article_li'

EditionLayout = require '../views/edition_layout'
ClaimLayout = require '../views/claim_layout'
standalone = true

getEntityViewByType = (model, refresh)->
  { type } = model
  displayMergeSuggestions = app.user.isAdmin

  getter = entityViewSpecialGetterByType[type]
  if getter? then return getter model, refresh

  View = entityViewByType[type]
  if View? then return new View { model, refresh, standalone, displayMergeSuggestions }

  { defaultClaimProperty: property } = model
  value = model.get 'uri'
  property or= 'wdt:P921'
  return new ClaimLayout { property, value, refresh }

getEditionView = (model, refresh)->
  model.waitForWorks
  .then -> new EditionLayout { model, refresh, standalone }

entityViewSpecialGetterByType =
  edition: getEditionView

module.exports = (args...)-> Promise.try getEntityViewByType.bind(null, args...)
