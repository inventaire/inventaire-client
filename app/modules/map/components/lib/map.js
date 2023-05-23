import { forceArray } from '#lib/utils'
import { compact, pluck } from 'underscore'

export const getDocsBounds = docsWithPosition => {
  docsWithPosition = forceArray(docsWithPosition)
  return compact(pluck(docsWithPosition, 'position'))
}
