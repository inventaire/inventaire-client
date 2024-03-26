import app from '#app/app'
import { buildPath } from '#lib/location'
import { forceArray } from '#lib/utils'
import endpoint from './endpoint.ts'

const { base } = endpoint('search')

export default function ({ types, search, limit = 10, offset = 0, exact = false, claim, filter }) {
  const { lang } = app.user
  types = forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit, offset, exact, claim, filter })
}
