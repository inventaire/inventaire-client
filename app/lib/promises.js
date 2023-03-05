import assert_ from '#lib/assert_types'
import error_ from '#lib/error'
import { reportError } from '#lib/reports'

export const props = async obj => {
  const keys = []
  const values = []
  for (const key in obj) {
    const value = obj[key]
    keys.push(key)
    values.push(value)
  }

  const res = await Promise.all(values)
  const resultObj = {}
  res.forEach((valRes, index) => {
    const key = keys[index]
    resultObj[key] = valRes
  })
  return resultObj
}

export const tryAsync = async fn => fn()

export const tap = fn => async res => {
  const tapRes = fn(res)
  if (tapRes instanceof Promise) await tapRes
  return res
}

export const map = fn => array => Promise.all(array.map(fn))

export const wait = ms => new Promise(resolve => setTimeout(resolve, ms))

// Isn't defined in test environment
if (window.addEventListener != null) {
  // See https://2ality.com/2016/04/unhandled-rejections.html
  window.addEventListener('unhandledrejection', event => {
    const err = event.reason
    console.error(`PossiblyUnhandledRejection: ${err.message}\n\n${err.stack}`, err, err.context)
    if (window.env === 'dev' && err.name === 'ChunkLoadError') window.location.reload()
    else reportError(err)
  })
}

// Returns a promise that resolves when the target object
// has the desired attribute set, and that the associated value has resolved
export const waitForAttribute = (obj, attribute, options = {}) => {
  assert_.object(obj)
  assert_.string(attribute)
  assert_.object(options)
  const { attemptTimeout = 100, maxAttempts = 100 } = options
  return new Promise((resolve, reject) => {
    let attempts = 0
    const checkAttribute = () => {
      try {
        if (obj[attribute] !== undefined) {
          resolve(obj[attribute])
        } else if (++attempts > maxAttempts) {
          const err = error_.new('too many attempts', 500, { obj, attribute })
          err.name = 'waitForAttributeError'
          reject(err)
        } else {
          setTimeout(checkAttribute, attemptTimeout)
        }
      } catch (err) {
        reject(err)
      }
    }
    checkAttribute()
  })
}

// Returns a promise that never resolves, that can be used
// as a placeholder while waiting for the real promise
export const getPromisePlaceholder = () => new Promise(() => {})
