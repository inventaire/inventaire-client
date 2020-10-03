import error_ from 'lib/error'

const oneDay = 24 * 60 * 60 * 1000
const iconAliases = {
  giving: 'heart',
  lending: 'refresh',
  selling: 'money',
  inventorying: 'cube'
}

// Will be overriden in modules/user/lib/i18n.js as soon as possible
export const i18n = _.identity
export const I18n = (...args) => _.capitalise(_.i18n.apply(_, args))

export const icon = (name, classes = '') => {
  name = iconAliases[name] || name
  return `<i class='fa fa-${name} ${classes}'></i>`
}

export const inspect = (obj, label) => {
  if (_.isArguments(obj)) { obj = _.toArray(obj) }
  // remove after using as it keeps reference of the inspected object
  // making the garbage collection impossible
  if (label != null) {
    _.log(obj, `${label} added to window['${label}'] for inspection`)
    window[label] = obj
  } else {
    if (window.current != null) {
      if (!window.previous) { window.previous = [] }
      window.previous.unshift(window.current)
    }
    window.current = obj
  }

  return obj
}

export const deepExtend = $.extend.bind($, true)

export const deepClone = obj => {
  _.type(obj, 'object')
  return JSON.parse(JSON.stringify(obj))
}

export const capitalise = str => {
  if (str === '') return ''
  return str[0].toUpperCase() + str.slice(1)
}

export const clickCommand = command => {
  return e => {
    if (_.isOpenedOutside(e)) {
    } else { app.execute(command) }
  }
}

export const isOpenedOutside = (e, ignoreMissingHref = false) => {
  let className, href, id
  if (e == null) return false

  if (e.currentTarget != null) { ({ id, href, className } = e.currentTarget) }

  if (e?.ctrlKey == null) {
    error_.report('non-event object was passed to isOpenedOutside', { id, href, className })
    // Better breaking an open outside behavior than not responding
    // to the event at all
    return false
  }

  if (!_.isNonEmptyString(href) && !ignoreMissingHref) {
    error_.report("can't open anchor outside: href is missing", { id, href, className })
    return false
  }

  const openInNewWindow = e.shiftKey
  // Anchor with a href are opened out of the current window when the ctrlKey is
  // pressed, or the metaKey (Command) in case its a Mac
  const openInNewTabByKey = isMac ? e.metaKey : e.ctrlKey
  // Known case of missing currentTarget: leaflet formatted events
  const openOutsideByTarget = e.currentTarget?.target === '_blank'
  return openInNewTabByKey || openInNewWindow || openOutsideByTarget
}

export const cutBeforeWord = (text, limit) => {
  const shortenedText = text.slice(0, +limit + 1 || undefined)
  return shortenedText.replace(/\s\w+$/, '')
}

export const lazyMethod = (methodName, delay = 200) => {
  return (...args) => {
    const lazyMethodName = `_lazy_${methodName}`
    if (this[lazyMethodName] == null) { this[lazyMethodName] = _.debounce(this[methodName].bind(this), delay) }
    return this[lazyMethodName].apply(this, args)
  }
}

export const invertAttr = ($target, a, b) => {
  const aVal = $target.attr(a)
  const bVal = $target.attr(b)
  $target.attr(a, bVal)
  return $target.attr(b, aVal)
}

export const daysAgo = epochTime => Math.floor((Date.now() - epochTime) / oneDay)

export const timeSinceMidnight = () => {
  const today = _.simpleDay()
  const midnight = new Date(today).getTime()
  return Date.now() - midnight
}

// Returns a .catch function that execute the reverse action
// then passes the error to the next .catch
export const Rollback = (reverseAction, label) => err => {
  if (label != null) _.log(`rollback: ${label}`)
  reverseAction()
  throw err
}

// Get the value from an object using a string
// (equivalent to lodash deep 'get' function).
// mimicking Lodash#get
export const get = (obj, prop) => prop.split('.').reduce(objectWalker, obj)

export const sum = array => array.reduce(add, 0)
export const trim = str => str.trim()

export const focusInput = $el => {
  $el.focus()
  const value = $el[0]?.value
  if (value == null) return
  return $el[0].setSelectionRange(0, value.length)
}

// adapted from http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
export const hashCode = string => {
  let [ hash, i, len ] = Array.from([ 0, 0, string.length ])
  if (len === 0) return hash

  while (i < len) {
    const chr = string.charCodeAt(i)
    hash = ((hash << 5) - hash) + chr
    hash |= 0 // Convert to 32bit integer
    i++
  }
  return Math.abs(hash)
}

export const haveAMatch = (arrayA, arrayB) => {
  if (!_.isArray(arrayA) || !_.isArray(arrayB)) return false
  for (const valueA of arrayA) {
    for (const valueB of arrayB) {
    // Return true as soon as possible
      if (valueA === valueB) return true
    }
  }
  return false
}

export const objLength = obj => Object.keys(obj)?.length
export const expired = (timestamp, ttl) => (Date.now() - timestamp) > ttl
export const shortLang = lang => lang?.slice(0, 2)

// encodeURIComponent ignores !, ', (, ), and *
// cf https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
export const fixedEncodeURIComponent = str => {
  return encodeURIComponent(str).replace(/[!'()*]/g, encodeCharacter)
}

export const pickOne = obj => {
  const key = Object.keys(obj)[0]
  if (key != null) return obj[key]
}

export const isDataUrl = str => /^data:image/.test(str)

export const parseBooleanString = (booleanString, defaultVal = false) => {
  if (defaultVal === false) {
    return booleanString === 'true'
  } else {
    return booleanString !== 'false'
  }
}

export const simpleDay = date => {
  if (date != null) {
    return new (Date(date).toISOString().split('T')[0])()
  } else { return new (Date().toISOString().split('T')[0])() }
}

export const isDateString = dateString => {
  if ((dateString == null) || (typeof dateString !== 'string')) return false
  return /^-?\d{4}(-\d{2})?(-\d{2})?$/.test(dateString)
}

// Missing in Underscore v1.8.3
export const chunk = (array, size) => {
// Do not mutate inital array
  array = array.slice(0)
  const chunks = []
  while (array.length > 0) {
    chunks.push(array.splice(0, size))
  }
  return chunks
}

const encodeCharacter = c => '%' + c.charCodeAt(0).toString(16)

const add = (a, b) => a + b

const objectWalker = (subObject, property) => subObject?.[property]

// Polyfill if needed
if (Date.now == null) { Date.now = () => new Date().getTime() }

// source: http://stackoverflow.com/questions/10527983/best-way-to-detect-mac-os-x-or-windows-computers-with-javascript-or-jquery
const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0
