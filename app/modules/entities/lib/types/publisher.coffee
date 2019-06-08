filterOutWdEditions = require '../filter_out_wd_editions'

module.exports = ->
  @childrenClaimProperty = 'wdt:P123'
  @subentitiesName = 'editions'
  _.extend @, specificMethods

specificMethods =
  beforeSubEntitiesAdd: filterOutWdEditions
