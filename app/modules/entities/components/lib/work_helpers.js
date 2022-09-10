import { authorsProps } from '#entities/components/lib/claims_helpers'

export const getPublishersUrisFromEditions = editions => {
  return _.uniq(_.compact(_.flatten(editions.map(edition => {
    return findFirstClaimValue(edition, 'wdt:P123')
  }))))
}

export const removeAuthorsClaims = claims => {
  const infoboxClaims = _.clone(claims)
  authorsProps.forEach(prop => {
    if (claims[prop]) delete infoboxClaims[prop]
  })
  return infoboxClaims
}

const findFirstClaimValue = (entity, prop) => {
  const values = entity?.claims[prop]
  if (!values || !values[0]) return
  return values[0]
}
