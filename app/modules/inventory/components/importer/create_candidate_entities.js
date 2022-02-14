import createEntity from '#entities/lib/create_entity'
import { createWorkEditionDraft } from '#entities/lib/create_entities'
import entityDraft from '#entities/lib/entity_draft_model'
import { isNonEmptyArray } from '#lib/boolean_tests'

export const createEntitiesByCandidate = async candidate => {
  const { customWorkTitle, customAuthorName } = candidate
  if (!candidate.authors && customAuthorName) {
    const authorDraft = entityDraft.createDraft({ type: 'human', label: customAuthorName, claims: {} })
    const authorEntity = await createEntity(authorDraft)
    if (authorEntity) candidate.authors = [ authorEntity ]
  }

  let workEntity
  if (!isNonEmptyArray(candidate.works) && customWorkTitle) {
    const workClaims = {}
    if (candidate.authors) {
      // TODO: handle several authors and remove candidate_row warning accordingly
      const { uri } = candidate.authors[0]
      if (uri) {
        workClaims['wdt:P50'] = [ uri ]
      }
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
