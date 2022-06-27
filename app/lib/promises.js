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
export const waitForAttribute = (obj, attribute, ms = 10) => {
  return new Promise(resolve => {
    const checkAttribute = () => {
      if (obj[attribute] != null) resolve(obj[attribute])
      else setTimeout(checkAttribute, ms)
    }
    checkAttribute()
  })
}
