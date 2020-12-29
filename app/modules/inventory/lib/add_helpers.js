import { localStorageProxy } from 'lib/local_storage'
import assert_ from 'lib/assert_types'

const set = localStorageProxy.setItem.bind(localStorageProxy)
const parsedGet = function (key) {
  const value = localStorageProxy.getItem(key)
  if (value === 'null') return null
  return value
}

export default function () {
  app.commands.setHandlers({
    // 'search' or 'scan:embedded'
    'last:add:mode:set': set.bind(null, 'lastAddMode'),
    // 'inventorying', 'giving', 'lending', 'selling'
    'last:transaction:set': set.bind(null, 'lastTransaction'),
    // 'private', 'network', 'groups'
    'last:listing:set': set.bind(null, 'lastListing'),
    'last:shelves:set' (shelves = []) {
      assert_.strings(shelves)
      return set('lastShelves', JSON.stringify(shelves))
    }
  })

  app.reqres.setHandlers({
    'last:add:mode:get': parsedGet.bind(null, 'lastAddMode'),
    'last:transaction:get': parsedGet.bind(null, 'lastTransaction'),
    'last:listing:get' () {
      const lastListing = parsedGet('lastListing')
      // Legacy support for friends listing
      if (lastListing === 'friends') return 'network'
      else return lastListing
    },
    'last:shelves:get' () {
      const shelves = parsedGet('lastShelves')
      if (shelves != null) return JSON.parse(shelves)
      else return []
    }
  })
}
