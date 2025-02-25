import { getEndpointBase } from '#app/api/endpoint'
import preq from '#app/lib/preq'
import type { ClientConfig } from '#server/controllers/config'
import log_ from './lib/loggers'

// Do not use API.config to avoid a circular dependency
const configEndpoint = getEndpointBase('config')

export const config: ClientConfig = await preq.get(configEndpoint)

export let bundleMeta

try {
  bundleMeta = await preq.get('/public/dist/bundle_meta.json')
} catch (err) {
  // Known case: if the client was not built
  log_.error(err, 'bundle meta fetch error')
  bundleMeta = {}
}
