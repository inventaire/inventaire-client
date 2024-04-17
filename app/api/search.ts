import app from '#app/app'
import { buildPath } from '#app/lib/location'
import { forceArray } from '#app/lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base } = getEndpointPathBuilders('search')

export default function ({ types, search, limit = 10, offset = 0, exact = false, claim, filter }) {
  const { lang } = app.user
  types = forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit, offset, exact, claim, filter })
}
