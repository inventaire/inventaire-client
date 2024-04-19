import '#app/init_globals.ts'
import config from 'config'

const { inventaireServerHost } = config

// @ts-expect-error TS2339
globalThis.window = globalThis.window || {}
// @ts-expect-error TS2339
globalThis.document = globalThis.document || {}

const nodeFetch = globalThis.fetch

globalThis.fetch = (url, body) => {
  url = `${inventaireServerHost}${url}`
  return nodeFetch(url, body)
}
