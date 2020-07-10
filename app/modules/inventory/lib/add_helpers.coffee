# just wrapping localStorage persisting of last add mode

set = localStorageProxy.setItem.bind localStorageProxy
parsedGet = (key)->
  value = localStorageProxy.getItem key
  if value is 'null' then return null
  return value

module.exports = ->
  app.commands.setHandlers
    # 'search' or 'scan:embedded'
    'last:add:mode:set': set.bind null, 'lastAddMode'
    # 'inventorying', 'giving', 'lending', 'selling'
    'last:transaction:set': set.bind null, 'lastTransaction'
    # 'private', 'network', 'groups'
    'last:listing:set': set.bind null, 'lastListing'

  app.reqres.setHandlers
    'last:add:mode:get': parsedGet.bind null, 'lastAddMode'
    'last:transaction:get': parsedGet.bind null, 'lastTransaction'
    'last:listing:get': ->
      lastListing = parsedGet 'lastListing'
      # Legacy support for friends listing
      if lastListing is 'friends' then 'network' else lastListing
