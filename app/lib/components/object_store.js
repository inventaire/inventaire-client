import { writable } from 'svelte/store'

export default function (storeValue = {}) {
  const { subscribe, set } = writable(storeValue)
  return {
    subscribe,

    setAttribute: (key, value) => {
      storeValue[key] = value
      // Trigger the update on subscribers
      set(storeValue)
    },

    assign: obj => set(Object.assign(storeValue, obj)),

    update: fn => {
      const updatedStoredValue = fn(storeValue)
      if (updatedStoredValue !== storeValue) throw new Error('should return the same object')
      set(updatedStoredValue)
    },

    // Directly access the store object. The alternative would be to
    // use 'get' from 'svelte/store', but it has unnecessary overhead
    // See https://github.com/sveltejs/svelte/issues/2060
    // and https://svelte.dev/docs#get
    get: () => storeValue
  }
}
