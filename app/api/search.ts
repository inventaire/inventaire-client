import app from '#app/app'
import { buildPath } from '#app/lib/location'
import { forceArray } from '#app/lib/utils'
import type { IndexedType } from '#server/types/search'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base } = getEndpointPathBuilders('search')

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
  const { lang } = app.user
  types = forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit, offset, exact, claim, filter })
}
