import { pick, flatten } from 'underscore'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { aggregateWorksClaims } from '#entities/components/lib/claims_helpers'
import { getEditionsWorks, getEntitiesByUris, getWorksAuthorsUris, getWorkAuthorsUris } from '#entities/lib/entities'

export async function fetchRelatedEntities (entities, parentEntityType) {
  if (isSubentitiesTypeEdition(parentEntityType)) {
    const relatedEntities = await getEditionsWorks(entities)
    Object.values(entities).forEach(pickAndAssignWorksClaims(relatedEntities))
  } else if (parentEntityType === 'human') {
    await addWorksAuthors(entities)
  }
}

const pickAndAssignWorksClaims = relatedEntities => edition => {
  const { claims } = edition
  const editionWorks = relatedEntities.filter(isClaimValue(claims))
  if (isNonEmptyArray(editionWorks)) {
    edition.claims = addWorksClaims(claims, editionWorks)
  }
}

export function addWorksClaims (claims, works) {
  const worksClaims = aggregateWorksClaims(works)
  const nonEmptyWorksClaims = pick(worksClaims, isNonEmptyArray)
  return Object.assign(claims, nonEmptyWorksClaims)
}

const isClaimValue = claims => entity => claims['wdt:P629'].includes(entity.uri)

export async function addWorksAuthors (works) {
  const authorsUris = flatten(getWorksAuthorsUris(works))
  const entities = await getEntitiesByUris({ uris: authorsUris })
  works.forEach(work => {
    const workAuthorUris = getWorkAuthorsUris(work)
    work.relatedEntities = pick(entities, workAuthorUris)
  })
}

const entitiesTypesWithSubentities = [ 'collection', 'publisher' ]

const isSubentitiesTypeEdition = type => entitiesTypesWithSubentities.includes(type)
