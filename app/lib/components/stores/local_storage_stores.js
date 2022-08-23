// Inspired by https://github.com/joshnuss/svelte-local-storage-store
// Note that svelte-local-storage-store also listen for storage events
// across windows, allowing to synchronize storage state between windows,
// which could come handy at some point
// Value serialization is always done in window.JSON, as it also allows to
// deserialize strings, numbers, and booleans as such

import { writable } from 'svelte/store'

const stores = {}

export function getLocalStorageStore (key, initialValue) {
  stores[key] = stores[key] || initStore(key, initialValue)
  return stores[key]
}

function initStore (key, initialValue) {
  const start = set => {
    const value = JSON.parse(localStorage.getItem(key))
    set(value)
    const stop = () => delete stores[key]
    return stop
  }
  const store = writable(initialValue, start)
  return {
    set (value) {
      localStorage.setItem(key, JSON.stringify(value))
      store.set(value)
    },
    subscribe: store.subscribe,
  }
}
