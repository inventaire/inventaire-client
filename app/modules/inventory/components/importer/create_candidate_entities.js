import createEntity from '#entities/lib/create_entity'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import entityDraft from '#entities/lib/entity_draft_model'
import { isNonEmptyArray } from '#lib/boolean_tests'

export const createEntitiesByCandidate = async candidate => {
  const { customWorkTitle, customAuthorsNames } = candidate
  if (!isNonEmptyArray(candidate.authors) && isNonEmptyArray(customAuthorsNames)) {
    const createdAuthorsEntities = await Promise.all(customAuthorsNames.map(authorName => {
      const authorDraft = entityDraft.createDraft({ type: 'human', label: authorName, claims: {} })
      return createEntity(authorDraft)
    }))
    if (isNonEmptyArray(createdAuthorsEntities)) candidate.authors = createdAuthorsEntities
  }

  let workEntity
  if (!isNonEmptyArray(candidate.works) && customWorkTitle) {
    const workClaims = {}
    if (isNonEmptyArray(candidate.authors)) {
      const authorsUris = candidate.authors.map(_.property('uri'))
      if (isNonEmptyArray(authorsUris)) workClaims['wdt:P50'] = authorsUris
    }
    const workDraft = entityDraft.createDraft({ type: 'work', label: customWorkTitle, claims: workClaims })
    workEntity = await createEntity(workDraft)
    if (workEntity) candidate.works = [ workEntity ]
  }

  if (!candidate.edition && isNonEmptyArray(candidate.works)) {
    const editionDraft = await createWorkEditionDraft({ workEntity, isbnData: candidate.isbnData })
    const editionEntity = await createEntity(editionDraft)
    if (editionEntity) candidate.edition = editionEntity
  }
  return candidate
}
