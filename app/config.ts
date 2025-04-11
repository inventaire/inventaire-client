import preq from '#app/lib/preq'
import type { ClientConfig } from '#server/controllers/config'

// Do not use API.config or getEndpointBase to avoid a circular dependency
const configEndpoint = '/api/config'

export const config: ClientConfig = await preq.get(configEndpoint)

export let bundleMeta

try {
  bundleMeta = await preq.get('/public/dist/bundle_meta.json')
} catch (err) {
  // Known case: if the client was not built
  // Using console directly to avoid circular dependencies
  console.error('bundle meta fetch error', err)
  bundleMeta = {}
}
