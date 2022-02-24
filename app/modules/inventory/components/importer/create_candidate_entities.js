import createEntity from '#entities/lib/create_entity'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import entityDraft from '#entities/lib/entity_draft_model'
import { isNonEmptyArray } from '#lib/boolean_tests'

export const createEntitiesByCandidate = async candidate => {
  const {
    customWorkTitle,
    customAuthorsNames,
    libraryThingWorkId,
  } = candidate

  if (!isNonEmptyArray(candidate.authors) && isNonEmptyArray(customAuthorsNames)) {
    candidate.authors = await createAuthors(customAuthorsNames)
  }

  if (!isNonEmptyArray(candidate.works) && customWorkTitle) {
    candidate.works = await createWorks(customWorkTitle, libraryThingWorkId)
  }

  if (!candidate.edition && isNonEmptyArray(candidate.works)) {
    candidate.edition = await createEdition(candidate)
  }
  return candidate
}

const createAuthors = async customAuthorsNames => {
  const createdAuthorsEntities = await Promise.all(customAuthorsNames.map(authorName => {
    const authorDraft = entityDraft.createDraft({ type: 'human', label: authorName, claims: {} })
    return createEntity(authorDraft)
  }))
  if (isNonEmptyArray(createdAuthorsEntities)) return createdAuthorsEntities
}

const createWorks = async (authors, customWorkTitle, libraryThingWorkId) => {
  const workClaims = {}
  if (isNonEmptyArray(authors)) {
    const authorsUris = authors.map(_.property('uri'))
    if (isNonEmptyArray(authorsUris)) workClaims['wdt:P50'] = authorsUris
  }
  if (libraryThingWorkId != null) workClaims['wdt:P1085'] = libraryThingWorkId

  const workDraft = entityDraft.createDraft({ type: 'work', label: customWorkTitle, claims: workClaims })
  const workEntity = await createEntity(workDraft)
  if (workEntity) return [ workEntity ]
}

const createEdition = async candidate => {
  const {
    isbnData,
    works,
    publicationDate,
    numberOfPages,
    goodReadsEditionId
  } = candidate

  const editionClaims = {}
  if (publicationDate != null) editionClaims['wdt:P577'] = publicationDate
  if (numberOfPages != null) editionClaims['wdt:P1104'] = numberOfPages
  if (goodReadsEditionId != null) editionClaims['wdt:P2969'] = goodReadsEditionId

  const editionDraft = await createWorkEditionDraft({ workEntity: works[0], isbnData, editionClaims })
  const editionEntity = await createEntity(editionDraft)
  if (editionEntity) return editionEntity
}
