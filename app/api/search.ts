import { config } from '#app/config'
import { buildPath } from '#app/lib/location'
import { forceArray } from '#app/lib/utils'
import { getCurrentLang } from '#modules/user/lib/i18n'
import type { Url } from '#server/types/common'
import type { IndexedType } from '#server/types/search'
import { getEndpointBase } from './endpoint.ts'

const base = getEndpointBase('search')
const { remoteEntitiesOrigin } = config
const entitiesSearchBase = `${remoteEntitiesOrigin || ''}${base}` as Url

interface SearchParams {
  types: IndexedType | IndexedType[]
  search: string
  limit?: number
  offset?: number
  exact?: boolean
  claim?: string
  filter?: string
}

export default function ({ types, search, limit = 10, offset = 0, exact = false, claim, filter }: SearchParams) {
  const hasSocialTypes = types.includes('users') || types.includes('groups')
  const endpoint = hasSocialTypes ? base : entitiesSearchBase
  return buildPath(endpoint, {
    types: forceArray(types).join('|'),
    search: encodeURIComponent(search),
    lang: getCurrentLang(),
    limit,
    offset,
    exact,
    claim,
    filter,
  })
}
