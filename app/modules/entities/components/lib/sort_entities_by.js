import { isNonEmptyArray } from '#lib/boolean_tests'
import { getSortingOptionsByNames } from '#entities/components/lib/works_browser_helpers'
import { getAndAssignPopularity } from '#entities/lib/entities'

const sortingPromises = {
  byPopularity: getAndAssignPopularity,
  byItemsOwnersCount: assignItemsToEditions,
}

export async function sortEntities ({ sortingType, sortingName, entities, waitingForItems }) {
  const optionsByNames = getSortingOptionsByNames(sortingType)
  const option = optionsByNames[sortingName]
  // sortingName = sortingName || Object.keys(optionsByNames)?.[0]
  const { sortFunction } = option
  if (sortFunction) {
    await waitForOptionPromise(sortingName, waitingForItems, entities)
  }
  return entities.sort(sortFunction)
}

export async function waitForOptionPromise (sortingName, waitingForPromise, entities) {
  const promiseFn = sortingPromises[sortingName]
  if (!promiseFn) return
  await promiseFn(entities, waitingForPromise)
}

export async function assignItemsToEditions (entities, waitingForPromise) {
  const editionsItems = await waitingForPromise
  const itemsByEditions = _.groupBy(editionsItems, 'entity')
  entities.forEach(assignItemsToEdition(itemsByEditions))
}

export const assignItemsToEdition = itemsByEditions => edition => {
  const items = itemsByEditions[edition.uri]
  if (!edition.items && isNonEmptyArray(items)) edition.items = items
}
