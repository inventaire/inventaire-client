import { aggregateWorksClaims, infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
import { isNonEmptyArray } from '#lib/boolean_tests'

export const addWorksClaims = (claims, works) => {
  const worksClaims = aggregateWorksClaims(works)
  const nonEmptyWorksClaims = _.pick(worksClaims, isNonEmptyArray)
  return Object.assign(claims, nonEmptyWorksClaims)
}

export const filterClaims = (_, key) => infoboxPropertiesByType.edition.includes(key)

export const isWorksClaimsContext = type => [ 'collection', 'publisher' ].includes(type)
