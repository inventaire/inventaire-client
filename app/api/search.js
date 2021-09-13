import { forceArray } from 'lib/utils'
import { buildPath } from 'lib/location'
import endpoint from './endpoint'
import { customizeInstance } from './instance'

const { base } = endpoint('search')

export default function (types, search, limit = 10, exact = false) {
  const { lang } = app.user
  types = forceArray(types)
  const hasSocialTypes = types.includes('users') || types.includes('groups')
  types = types.join('|')
  search = encodeURIComponent(search)
  const url = buildPath(base, { types, search, lang, limit, exact })
  if (hasSocialTypes) return url
  else return customizeInstance(url)
}
