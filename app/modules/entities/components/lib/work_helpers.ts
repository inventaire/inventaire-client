import { uniq, omit, flatten, compact } from 'underscore'
import { authorsProps } from '#entities/components/lib/claims_helpers'

export const getPublishersUrisFromEditions = editions => {
  return uniq(compact(flatten(editions.map(edition => {
    return findFirstClaimValue(edition, 'wdt:P123')
  }))))
}

export const omitNonInfoboxClaims = claims => {
  const omitProps = [ ...authorsProps, 'wdt:P1680' ]
  return omitClaims(claims, omitProps)
}

export const omitClaims = (claims, properties) => {
  return omit(claims, properties.flat())
}

const findFirstClaimValue = (entity, prop) => {
  const values = entity?.claims[prop]
  if (!values || !values[0]) return
  return values[0]
}
