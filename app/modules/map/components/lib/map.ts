import { compact, pluck } from 'underscore'
import { forceArray } from '#lib/utils'

export const getDocsBounds = docsWithPosition => {
  docsWithPosition = forceArray(docsWithPosition)
  return compact(pluck(docsWithPosition, 'position'))
}
