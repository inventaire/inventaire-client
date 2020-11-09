export default function typeOf (obj) {
  // just handling what differes from typeof
  const type = typeof obj
  if (type === 'object') {
    if (_.isNull(obj)) return 'null'
    if (_.isArray(obj)) return 'array'
  }
  if (type === 'number') {
    if (_.isNaN(obj)) return 'NaN'
  }
  return type
}
