publicDomainThresholdYear = new Date().getFullYear() - 70
commonsSerieWork = require './commons_serie_work'
getEntityItemsByCategories = require '../get_entity_items_by_categories'
filterOutWdEditions = require '../filter_out_wd_editions'

module.exports = ->
  @childrenClaimProperty = 'wdt:P123'

  @subentitiesName = 'editions'
  # extend before fetching sub entities to have access
  # to the custom @beforeSubEntitiesAdd
  _.extend @, specificMethods

  @fetchSubEntities @refresh

  @waitForSubentities

specificMethods = _.extend {},
  # Discard Wikidata editions for now has they don't integrate well
  subEntitiesUrisFilter: (uri)-> uri.split(':')[0] isnt 'wd'
  getItemsByCategories: getEntityItemsByCategories
  beforeSubEntitiesAdd: filterOutWdEditions