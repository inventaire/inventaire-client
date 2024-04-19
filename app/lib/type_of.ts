import { isNull, isNaN, isArray } from 'underscore'

export default function typeOf (obj?: unknown) {
  // just handling what differes from typeof
  const type = typeof obj
  if (type === 'object') {
    if (isNull(obj)) return 'null'
    if (isArray(obj)) return 'array'
  }
  if (type === 'number') {
    if (isNaN(obj)) return 'NaN'
  }
  return type
}
