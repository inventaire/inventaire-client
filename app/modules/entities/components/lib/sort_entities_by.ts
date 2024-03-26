import { groupBy } from 'underscore'
import { getAndAssignPopularity } from '#entities/lib/entities'
import { isNonEmptyArray } from '#lib/boolean_tests'

const sortingPromises = {
  byPopularity: getAndAssignPopularity,
  byItemsOwnersCount: assignItemsToEditions,
}

export async function sortEntities ({ option, entities, promise }) {
  const { sortFunction, value: sortingName } = option
  if (!sortFunction) return entities
  const sortingPromise = sortingPromises[sortingName]
  // TODO: find a way to not re assign items every time sortEntities is triggered
  if (sortingPromise) await sortingPromise({ entities, promise })
  return entities.sort(sortFunction)
}

export async function assignItemsToEditions ({ entities, promise: waitingForItems }) {
  const editionsItems = await waitingForItems
  const itemsByEditions = groupBy(editionsItems, 'entity')
  entities.forEach(assignItemsToEdition(itemsByEditions))
}

export const assignItemsToEdition = itemsByEditions => edition => {
  if (edition.items) return
  const items = itemsByEditions[edition.uri]
  if (isNonEmptyArray(items)) edition.items = items
}
