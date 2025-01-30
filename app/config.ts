import { getEndpointBase } from '#app/api/endpoint'
import preq from '#app/lib/preq'
import type { ClientConfig } from '#server/controllers/config'

// Do not use API.config to avoid a circular dependency
const configEndpoint = getEndpointBase('config')

export const config: ClientConfig = await preq.get(configEndpoint)
