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
  beforeSubEntitiesAdd: filterOutWdEditions
