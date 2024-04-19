import { API } from '#app/api/api'
import preq from '#app/lib/preq'

export const config = await preq.get(API.config)
