// This store factory returns per-document stores, so that component can atomically
// decide for which document they want to subscribe for changes.
// This is preferable to having a single big store containing all the documents,
// as that would trigger unnecessary updates on all the subscribed components

import { writable } from 'svelte/store'

const docStores = {}

export function getDocStore ({ category, doc }) {
  const { _id: id } = doc
  let store = docStores[category]?.[id]
  if (store) {
    store.set(doc)
  } else {
    store = initDocStore({ category, id, doc })
  }
  return store
}

export function refreshDocStore ({ category, doc }) {
  const { _id: id } = doc
  const store = docStores[category]?.[id]
  if (store) store.set(doc)
}

function initDocStore ({ category, id, doc }) {
  // `stopDocStore` will be called when there are no more subscribers
  const stopDocStore = () => {
    // Delete the document store to prevent free the memory
    delete docStores[category][id]
  }
  const store = writable(doc, () => stopDocStore)
  docStores[category] = docStores[category] || {}
  docStores[category][id] = store
  return store
}

export function updateDocStore ({ category, id, updateFn }) {
  const store = docStores[category]?.[id]
  if (store) store.update(updateFn)
}

export function hasSubscribers (category, id) {
  return docStores[category]?.[id] != null
}
