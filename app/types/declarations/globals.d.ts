// This is the result of trial and errors, rather than a clear understanding of how to declare global object types

// There might be a better/more idomatic way
declare namespace L {}

interface Window {
  app: unknown
  opera: unknown
  _paq: unknown[]
  prerenderReady: boolean
}
