import { forceArray } from 'lib/utils'
import { buildPath } from 'lib/location'
import endpoint from './endpoint'
const { base } = endpoint('search')

export default function (types, search, limit = 10) {
  const { lang } = app.user
  types = forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit })
};
