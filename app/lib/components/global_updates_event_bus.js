// This is a small implementation of a global event bus to make
// cross-non-hierachically-related-components data sync work while waiting
// for a more solid global state management strategy.
// It might be suboptimal, especially in terms of the implied verbosity in consumers,
// which have to subscribe/unsubscribe manually: maybe this could be replaced by Svelte Stores, but collections of global Svelte Stores doesn't seem trivial.

import { without } from 'underscore'

const subscriptions = {}

export function subscribe (category, id, callback) {
  subscriptions[category] = subscriptions[category] || {}
  subscriptions[category][id] = subscriptions[category][id] || []
  subscriptions[category][id].push(callback)
}

export function unsubscribe (category, id, callback) {
  if (subscriptions[category]?.[id] == null) return
  subscriptions[category][id] = without(subscriptions[category][id], callback)
}

export function update (category, doc) {
  const { _id: id } = doc
  if (subscriptions[category]?.[id] == null) return
  subscriptions[category][id].forEach(callback => callback(doc))
}

export function hasSubscribers (category, id) {
  return subscriptions[category]?.[id] != null
}
