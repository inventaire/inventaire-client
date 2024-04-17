import { isArray, debounce } from 'underscore'
import app from '#app/app'
import assert_ from '#app/lib/assert_types'
import { isNonEmptyString } from '#app/lib/boolean_tests'
import { serverReportError } from '#app/lib/error'
import { currentRoute } from '#app/lib/location'
import log_ from '#app/lib/loggers'

export function deepClone (obj: unknown) {
  assert_.object(obj)
  return JSON.parse(JSON.stringify(obj))
}

export function capitalize (str: string) {
  if (str === '') return ''
  return str[0].toUpperCase() + str.slice(1)
}

export const clickCommand = (command: string) => e => {
  if (!isOpenedOutside(e)) app.execute(command)
}

export function isOpenedOutside (e, ignoreMissingHref = false) {
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
export function loadInternalLink (e) {
  if (!(isOpenedOutside(e))) {
    const { pathname, search } = new URL(e.currentTarget.href)
    app.navigateAndLoad(`${pathname}${search}`, {
      preventScrollTop: isModalPathname(pathname),
    })
    e.preventDefault()
  }
}

export function showLoginPageAndRedirectHere () {
  app.request('require:loggedIn', currentRoute())
}

const isModalPathname = pathname => modalPathnamesPattern.test(pathname)
// Ideally, this could be declared within the routers
const modalPathnamesPattern = /^\/items\/\w+/

export function cutBeforeWord (text: string, limit: number) {
  if (text.length <= limit) return text
  const shortenedText = text.slice(0, limit)
  return shortenedText.replace(/\s\w+$/, '')
}

export function truncateText (text: string, limit: number) {
  const truncatedText = cutBeforeWord(text, limit)
  if (truncatedText.length < text.length) return `${truncatedText.trim()}…`
  else return truncatedText
}

export function lazyMethod (methodName: string, delay: number = 200) {
  return function (...args) {
    const lazyMethodName = `_lazy_${methodName}`
    if (this[lazyMethodName] == null) {
      this[lazyMethodName] = debounce(this[methodName].bind(this), delay)
    }
    return this[lazyMethodName](...args)
  }
}

// Returns a .catch function that execute the reverse action
// then passes the error to the next .catch
export const Rollback = (reverseAction, label) => err => {
  if (label != null) log_.info(`rollback: ${label}`)
  reverseAction()
  throw err
}

const add = (a: number, b: number) => a + b
export const sum = (array: number[]) => array.reduce(add, 0)

export const trim = (str: string) => str.trim()

export const focusInput = $el => {
  $el.focus()
  const value = $el[0]?.value
  if (value == null) return
  return $el[0].setSelectionRange(0, value.length)
}

// Adapted from https://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
export function hashCode (string: string) {
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

export function someMatch (arrayA: unknown[], arrayB: unknown[]) {
  if (!isArray(arrayA) || !isArray(arrayB)) return false
  for (const valueA of arrayA) {
    for (const valueB of arrayB) {
    // Return true as soon as possible
      if (valueA === valueB) return true
    }
  }
  return false
}

export const objLength = (obj: unknown) => Object.keys(obj)?.length

export const shortLang = (lang: string) => lang?.slice(0, 2)

// encodeURIComponent ignores !, ', (, ), and *
// cf https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
export function fixedEncodeURIComponent (str: string) {
  return encodeURIComponent(str).replace(/[!'()*]/g, encodeCharacter)
}

const encodeCharacter = (c: string) => '%' + c.charCodeAt(0).toString(16)

export function pickOne (obj: unknown) {
  const key = Object.keys(obj)[0]
  if (key != null) return obj[key]
}

export function parseBooleanString (booleanString: string, defaultVal: boolean = false) {
  if (defaultVal === false) {
    return booleanString === 'true'
  } else {
    return booleanString !== 'false'
  }
}

// Missing in Underscore v1.8.3
export function chunk (array: unknown[], size: number) {
// Do not mutate inital array
  array = array.slice(0)
  const chunks = []
  while (array.length > 0) {
    chunks.push(array.splice(0, size))
  }
  return chunks
}

export function forceArray (keys?: unknown) {
  if ((keys == null) || (keys === '')) return []
  if (!isArray(keys)) return [ keys ]
  else return keys
}

export async function asyncNoop () {}

export function bubbleUpChildViewEvent (eventName: string) {
  return function (...args) {
    this.triggerMethod(eventName, ...args)
  }
}

export const dropLeadingSlash = (str: string) => str.replace(/^\//, '')

export function setIntersection <T> (a, b) {
  let set, arrayOrSet
  if (a instanceof Set) {
    set = a
    arrayOrSet = b
  } else {
    set = b
    arrayOrSet = a
  }
  const intersection = Array.from(arrayOrSet).filter(value => set.has(value)) as T[]
  return new Set(intersection)
}

export function convertEmToPx (em: number) {
  const emToPxRatio = parseFloat(getComputedStyle(document.body).fontSize)
  return em * emToPxRatio
}

export function flatMapKeyValues (object, fn) {
  assert_.object(object)
  assert_.function(fn)
  // @ts-expect-error
  return Object.fromEntries(Object.entries(object).flatMap(fn))
}

export function sortObjectKeys (object, fn) {
  assert_.object(object)
  assert_.function(fn)
  return Object.fromEntries(Object.entries(object).sort(([ keyA ], [ keyB ]) => {
    return fn(keyA, keyB)
  }))
}

// Source: https://www.totaltypescript.com/tips/create-your-own-objectkeys-function-using-generics-and-the-keyof-operator
export function objectKeys <Obj> (obj: Obj) {
  return Object.keys(obj) as (keyof Obj)[]
}

// Work around the TS2345 error when using Array include method
// https://stackoverflow.com/questions/55906553/typescript-unexpected-error-when-using-includes-with-a-typed-array/70532727#70532727
export function arrayIncludes (array: readonly (string | number)[], value: string | number) {
  return array.some(element => element === value)
}
