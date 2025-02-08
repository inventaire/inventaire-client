import assert_ from '#app/lib/assert_types'
import { newError } from '#app/lib/error'
import { reportError } from '#app/lib/reports'

export async function props (obj: Record<string, unknown>) {
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
  return resultObj as Record<keyof typeof obj, Awaited<typeof obj[keyof typeof obj]>>
}

export const tryAsync = async fn => fn()

export const tap = fn => async res => {
  const tapRes = fn(res)
  if (tapRes instanceof Promise) await tapRes
  return res
}

export const map = fn => array => Promise.all(array.map(fn))

export const wait = (ms: number) => new Promise(resolve => setTimeout(resolve, ms))

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
export async function waitForAttribute (obj, attribute, options: { attemptTimeout?: number, maxAttempts?: number } = {}) {
  assert_.object(obj)
  assert_.string(attribute)
  assert_.object(options)
  const { attemptTimeout = 100, maxAttempts = 100 } = options
  return new Promise((resolve, reject) => {
    let attempts = 0
    function checkAttribute () {
      try {
        if (obj[attribute] !== undefined) {
          resolve(obj[attribute])
        } else if (++attempts > maxAttempts) {
          const err = newError('too many attempts', 500, { obj, attribute })
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
