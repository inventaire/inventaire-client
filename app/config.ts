import { getEndpointBase } from '#app/api/endpoint'
import preq from '#app/lib/preq'

// Do not use API.config to avoid a circular dependency
const configEndpoint = getEndpointBase('config')

export const config = await preq.get(configEndpoint)
