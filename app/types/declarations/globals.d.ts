// This is the result of trial and errors, rather than a clear understanding of how to declare global object types
// There might be a better/more idomatic way
declare module jQuery {}
declare module Backbone {}
declare module Marionette {}
declare module L {}

interface Window {
  env: string
  opera: unknown
  _paq: unknown[]
  jQuery: unknown
  Marionette: unknown
  $: unknown
  prerenderReady: boolean
}

interface Navigator {
  // IE only
  // from https://stackoverflow.com/questions/40382056/typescript-navigator-merging-with-lib-d-ts
  userLanguage?: string
}
