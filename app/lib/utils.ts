import { isArray, debounce } from 'underscore'
import app from '#app/app'
import assert_ from '#lib/assert_types'
import { isNonEmptyString } from '#lib/boolean_tests'
import { serverReportError } from '#lib/error'
import { currentRoute } from '#lib/location'
import log_ from '#lib/loggers'

export const deepClone = obj => {
  assert_.object(obj)
  return JSON.parse(JSON.stringify(obj))
}

export const capitalize = str => {
  if (str === '') return ''
  return str[0].toUpperCase() + str.slice(1)
}

export const clickCommand = command => e => {
  if (!isOpenedOutside(e)) app.execute(command)
}

export const isOpenedOutside = (e, ignoreMissingHref = false) => {
  let className, href, id
  if (e == null) return false

  if (e.currentTarget != null) ({ id, href, className } = e.currentTarget)

  if (e?.ctrlKey == null) {
    serverReportError('non-event object was passed to isOpenedOutside', { id, href, className })
    // Better breaking an open outside behavior than not responding
    // to the event at all
    return false
  }

  if (!isNonEmptyString(href) && !ignoreMissingHref) {
    serverReportError("can't open anchor outside: href is missing", { id, href, className })
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

// source: https://stackoverflow.com/questions/10527983/best-way-to-detect-mac-os-x-or-windows-computers-with-javascript-or-jquery
// Test existance to ignore in other contexts than the browser
const isMac = window.navigator?.platform.toUpperCase().indexOf('MAC') >= 0

// TODO: consider having a global event listener,
// rather than having to set it in all those <a on:click>
export const loadInternalLink = e => {
  if (!(isOpenedOutside(e))) {
    const { pathname, search } = new URL(e.currentTarget.href)
    app.navigateAndLoad(`${pathname}${search}`, {
      preventScrollTop: isModalPathname(pathname),
    })
    e.preventDefault()
  }
}

export const showLoginPageAndRedirectHere = () => {
  app.request('require:loggedIn', currentRoute())
}

const isModalPathname = pathname => modalPathnamesPattern.test(pathname)
// Ideally, this could be declared within the routers
const modalPathnamesPattern = /^\/items\/\w+/

export const cutBeforeWord = (text, limit) => {
  if (text.length <= limit) return text
  const shortenedText = text.slice(0, limit)
  return shortenedText.replace(/\s\w+$/, '')
}

export const truncateText = (text, limit) => {
  const truncatedText = cutBeforeWord(text, limit)
  if (truncatedText.length < text.length) return `${truncatedText.trim()}…`
  else return truncatedText
}

export const lazyMethod = (methodName, delay = 200) => {
  return function (...args) {
    const lazyMethodName = `_lazy_${methodName}`
    if (this[lazyMethodName] == null) {
      this[lazyMethodName] = debounce(this[methodName].bind(this), delay)
    }
    return this[lazyMethodName](...args)
  }
}

export const invertAttr = ($target, a, b) => {
  const aVal = $target.attr(a)
  const bVal = $target.attr(b)
  $target.attr(a, bVal)
  return $target.attr(b, aVal)
}

// Returns a .catch function that execute the reverse action
// then passes the error to the next .catch
export const Rollback = (reverseAction, label) => err => {
  if (label != null) log_.info(`rollback: ${label}`)
  reverseAction()
  throw err
}

const add = (a, b) => a + b
export const sum = array => array.reduce(add, 0)

export const trim = str => str.trim()

export const focusInput = $el => {
  $el.focus()
  const value = $el[0]?.value
  if (value == null) return
  return $el[0].setSelectionRange(0, value.length)
}

// Adapted from https://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
export const hashCode = string => {
  let [ hash, i, len ] = [ 0, 0, string.length ]
  if (len === 0) return hash

  while (i < len) {
    const chr = string.charCodeAt(i)
    hash = ((hash << 5) - hash) + chr
    hash |= 0 // Convert to 32bit integer
    i++
  }
  return Math.abs(hash)
}

export const someMatch = (arrayA, arrayB) => {
  if (!isArray(arrayA) || !isArray(arrayB)) return false
  for (const valueA of arrayA) {
    for (const valueB of arrayB) {
    // Return true as soon as possible
      if (valueA === valueB) return true
    }
  }
  return false
}

export const objLength = obj => Object.keys(obj)?.length

export const shortLang = lang => lang?.slice(0, 2)

// encodeURIComponent ignores !, ', (, ), and *
// cf https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
export const fixedEncodeURIComponent = str => {
  return encodeURIComponent(str).replace(/[!'()*]/g, encodeCharacter)
}

const encodeCharacter = c => '%' + c.charCodeAt(0).toString(16)

export const pickOne = obj => {
  const key = Object.keys(obj)[0]
  if (key != null) return obj[key]
}

export const parseBooleanString = (booleanString, defaultVal = false) => {
  if (defaultVal === false) {
    return booleanString === 'true'
  } else {
    return booleanString !== 'false'
  }
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

export function forceArray (keys) {
  if ((keys == null) || (keys === '')) return []
  if (!isArray(keys)) return [ keys ]
  else return keys
}

export async function asyncNoop () {}

export const bubbleUpChildViewEvent = function (eventName) {
  return function (...args) {
    this.triggerMethod(eventName, ...args)
  }
}

export const dropLeadingSlash = str => str.replace(/^\//, '')

export const setIntersection = (a, b) => {
  let set, arrayOrSet
  if (a instanceof Set) {
    set = a
    arrayOrSet = b
  } else {
    set = b
    arrayOrSet = a
  }
  const intersection = Array.from(arrayOrSet).filter(value => set.has(value))
  return new Set(intersection)
}

export function convertEmToPx (em) {
  const emToPxRatio = parseFloat(getComputedStyle(document.body).fontSize)
  return em * emToPxRatio
}

export function flatMapKeyValues (object, fn) {
  assert_.object(object)
  assert_.function(fn)
  return Object.fromEntries(Object.entries(object).flatMap(fn))
}

export function sortObjectKeys (object, fn) {
  assert_.object(object)
  assert_.function(fn)
  return Object.fromEntries(Object.entries(object).sort(([ keyA ], [ keyB ]) => {
    return fn(keyA, keyB)
  }))
}
