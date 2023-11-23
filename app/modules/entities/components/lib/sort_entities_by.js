import { isNonEmptyArray } from '#lib/boolean_tests'
import { getAndAssignPopularity } from '#entities/lib/entities'

const sortingPromises = {
  byPopularity: getAndAssignPopularity,
  byItemsOwnersCount: assignItemsToEditions,
}

export async function sortEntities ({ sortingType, option, entities, waitingForItems }) {
  const { sortFunction, value: sortingName } = option
  if (!sortFunction) return entities
  await assignSortingDataToEntities(sortingName, waitingForItems, entities)
  return entities.sort(sortFunction)
}

export async function assignSortingDataToEntities (sortingName, waitingForItems, entities) {
  const promiseFn = sortingPromises[sortingName]
  if (!promiseFn) return
  const editionsItems = await waitingForItems
  await promiseFn({ entities, editionsItems })
}

export async function assignItemsToEditions ({ entities, editionsItems }) {
  const itemsByEditions = _.groupBy(editionsItems, 'entity')
  entities.forEach(assignItemsToEdition(itemsByEditions))
}

export const assignItemsToEdition = itemsByEditions => edition => {
  const items = itemsByEditions[edition.uri]
  if (!edition.items && isNonEmptyArray(items)) edition.items = items
}
