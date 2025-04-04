import { localStorageProxy } from '#app/lib/local_storage'

const set = localStorageProxy.setItem.bind(localStorageProxy)

const getArraySetter = (key: string) => (array: unknown[]) => {
  return set(key, JSON.stringify(array))
}

function parsedGet (key: string) {
  const value = localStorageProxy.getItem(key)
  if (value === 'null') return null
  return value
}

const getArrayGetter = (key: string) => () => {
  const array = parsedGet(key)
  if (array != null) return JSON.parse(array)
  else return []
}

export const getLastAddMode = parsedGet.bind(null, 'lastAddMode')
export const getLastTransaction = parsedGet.bind(null, 'lastTransaction')
export const getLastShelves = getArrayGetter('lastShelves')
export const getLastVisbility = getArrayGetter('lastVisbility')

// 'search' or 'scan:embedded'
export const setLastAddMode = set.bind(null, 'lastAddMode')
// 'inventorying', 'giving', 'lending', 'selling'
export const setLastTransaction = set.bind(null, 'lastTransaction')
export const setLastShelves = getArraySetter('lastShelves')
// An array of visibility keys
export const setLastVisbility = getArraySetter('lastVisbility')
