// If localStorage isnt supported (or more probably, blocked),
// replace it by a global object: data won't be persisted
// from one session to the other, but who's fault is that
let _localStorageProxy
try {
  window.localStorage.setItem('localStorage-support', 'true')
  _localStorageProxy = localStorage
} catch (err) {
  console.warn('localStorage isnt supported', err)
  let storage = {}
  _localStorageProxy = {
    getItem (key) { return storage[key] || null },
    setItem (key, value) {
      storage[key] = value
    },
    clear () { storage = {} },
  }
}

export const localStorageProxy = _localStorageProxy
