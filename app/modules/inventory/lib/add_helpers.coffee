# just wrapping localStorage persisting of last add mode

set = localStorage.setItem.bind localStorage
get = localStorage.getItem.bind localStorage

module.exports = ->
  app.commands.setHandlers
    # 'scan' or 'search'
    'last:add:mode:set': set.bind null, 'lastAddMode'
    # 'inventorying', 'giving', 'lending', 'selling'
    'last:transaction:set': set.bind null, 'lastTransaction'
    # 'private', 'friends', 'groups'
    'last:listing:set': set.bind null, 'lastListing'

  app.reqres.setHandlers
    'last:add:mode:get': get.bind null, 'lastAddMode'
    'last:transaction:get': get.bind null, 'lastTransaction'
    'last:listing:get': get.bind null, 'lastListing'
