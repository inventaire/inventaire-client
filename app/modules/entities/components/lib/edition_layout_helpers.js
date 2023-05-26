import { aggregateWorksClaims } from '#entities/components/lib/claims_helpers'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { pick } from 'underscore'

export const addWorksClaims = (claims, works) => {
  const worksClaims = aggregateWorksClaims(works)
  const nonEmptyWorksClaims = pick(worksClaims, isNonEmptyArray)
  return Object.assign(claims, nonEmptyWorksClaims)
}

const entitiesTypesWithEditionsSubentities = [ 'collection', 'publisher' ]
export const isSubentitiesTypeEdition = type => entitiesTypesWithEditionsSubentities.includes(type)
