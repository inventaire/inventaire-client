import { forceArray } from '#lib/utils'
import { buildPath } from '#lib/location'
import endpoint from './endpoint.js'
const { base } = endpoint('search')

export default function ({ types, search, limit = 10, offset = 0, exact = false, claim, filter }) {
  const { lang } = app.user
  types = forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit, offset, exact, claim, filter })
}
