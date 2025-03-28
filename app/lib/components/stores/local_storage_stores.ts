// Inspired by https://github.com/joshnuss/svelte-local-storage-store
// Note that svelte-local-storage-store also listen for storage events
// across windows, allowing to synchronize storage state between windows,
// which could come handy at some point
// Value serialization is always done in window.JSON, as it also allows to
// deserialize strings, numbers, and booleans as such

import { writable } from 'svelte/store'
import { serverReportError } from '#app/lib/error'
import { localStorageProxy } from '#app/lib/local_storage'

const stores = {}

export function getLocalStorageStore (key, initialValue) {
  stores[key] = stores[key] || initStore(key, initialValue)
  return stores[key]
}

function initStore (key, initialValue) {
  const start = set => {
    let value, stringifiedStoredValue
    try {
      stringifiedStoredValue = localStorageProxy.getItem(key)
      value = JSON.parse(stringifiedStoredValue)
    } catch (err) {
      if (err.name === 'SyntaxError') localStorageProxy.removeItem(key)
      serverReportError(err, { key, initialValue, stringifiedStoredValue })
    }
    if (value == null) value = initialValue
    set(value)
    const stop = () => delete stores[key]
    return stop
  }
  const store = writable(initialValue, start)
  return {
    set (value) {
      // There is no known case yet, where saving an empty value is the desired behavior
      // There is a known case where the store is shortly assigned an empty value:
      // when binding the store to an input, the value may start by being undefined
      if (value != null) {
        localStorageProxy.setItem(key, JSON.stringify(value))
      }
      store.set(value)
    },
    subscribe: store.subscribe,
  }
}
