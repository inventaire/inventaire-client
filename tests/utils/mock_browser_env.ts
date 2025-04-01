import config from 'config'

const { inventaireServerHost } = config

// @ts-expect-error TS2339
globalThis.window ??= {}
// @ts-expect-error TS2339
globalThis.document ??= {}
// @ts-expect-error
globalThis.location ??= {
  origin: 'http://localhost:9999',
}

const nodeFetch = globalThis.fetch

globalThis.fetch = (url, body) => {
  url = `${inventaireServerHost}${url}`
  return nodeFetch(url, body)
}
