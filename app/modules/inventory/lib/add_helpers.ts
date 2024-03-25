import assert_ from '#lib/assert_types'
import { localStorageProxy } from '#lib/local_storage'

const set = localStorageProxy.setItem.bind(localStorageProxy)
const SetArray = key => array => {
  assert_.strings(array)
  return set(key, JSON.stringify(array))
}

const parsedGet = function (key) {
  const value = localStorageProxy.getItem(key)
  if (value === 'null') return null
  return value
}

const GetArray = key => () => {
  const array = parsedGet(key)
  if (array != null) return JSON.parse(array)
  else return []
}

export default function () {
  app.commands.setHandlers({
    // 'search' or 'scan:embedded'
    'last:add:mode:set': set.bind(null, 'lastAddMode'),
    // 'inventorying', 'giving', 'lending', 'selling'
    'last:transaction:set': set.bind(null, 'lastTransaction'),
    // An array of visibility keys
    'last:visibility:set': SetArray('lastVisbility'),
    'last:shelves:set': SetArray('lastShelves'),
  })

  app.reqres.setHandlers({
    'last:add:mode:get': parsedGet.bind(null, 'lastAddMode'),
    'last:transaction:get': parsedGet.bind(null, 'lastTransaction'),
    'last:visibility:get': GetArray('lastVisbility'),
    'last:shelves:get': GetArray('lastShelves'),
  })
}
