import { clone, flatten, intersection, pick, uniq, without } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import { getLocalStorageStore } from '#app/lib/components/stores/local_storage_stores'
import { serverReportError } from '#app/lib/error'
import preq from '#app/lib/preq'
import { objectEntries } from '#app/lib/utils'
import { getEntitiesAttributesByUris } from '#entities/lib/entities'
import type { CouchDoc } from '#server/types/couchdb'

export async function getSelectorsData ({ worksTree }) {
  const facets = worksTree
  const facetsSelectedValues = {}
  const authorsUris = Object.keys(worksTree.author)
  const genresUris = Object.keys(worksTree.genre)
  const subjectsUris = Object.keys(worksTree.subject)

  let valuesUris = flatten([ authorsUris, genresUris, subjectsUris ])
  // The 'unknown' attribute is used to list works that have no value
  // for one of those selector properties
  // Removing the 'unknown' URI is here required as 'get:entities:models'
  // won't know how to resolve it
  valuesUris = without(valuesUris, 'unknown')

  const facetsEntitiesBasicInfo = await getEntitiesBasicInfo(valuesUris)

  const facetsSelectors = getSelectorsOptions({ worksTree, facetsEntitiesBasicInfo })

  return {
    facets,
    facetsEntitiesBasicInfo,
    facetsSelectedValues,
    facetsSelectors,
  }
}

async function getEntitiesBasicInfo (uris) {
  uris = uniq(uris)
  if (uris.length === 0) return []
  const res = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels', 'image' ],
    lang: app.user.lang,
  })
  const entities = res.entities
  Object.values(entities).forEach(entity => {
    if (entity.labels == null) {
      serverReportError('missing entity labels', { entity, uris })
      entity.label = ''
    } else {
      entity.label = Object.values(entity.labels)[0]
    }
  })
  return entities
}

interface FacetSelector {
  options: {
    value: string
    image: string
    text: string
    count: number
    worksUris: string[]
  }[]
  disabled?: boolean
}

const getSelectorsOptions = ({ worksTree, facetsEntitiesBasicInfo }) => {
  const facetsSelectors = {}
  for (const [ sectionName, worksUrisPerValue ] of objectEntries(worksTree)) {
    if (sectionName !== 'owner') {
      const facetSelector: FacetSelector = {
        options: getOptions({ worksUrisPerValue, facetsEntitiesBasicInfo }),
      }
      facetSelector.disabled = hasNoKnownValue(facetSelector.options)
      facetsSelectors[sectionName] = facetSelector
    }
  }
  return facetsSelectors
}

const getOptions = ({ worksUrisPerValue, facetsEntitiesBasicInfo }) => {
  return Object.keys(worksUrisPerValue)
  .map(formatOption({ worksUrisPerValue, facetsEntitiesBasicInfo }))
  .sort(byCount)
}

const hasNoKnownValue = options => {
  return !options.some(option => option.value !== 'unknown')
}

const byCount = (a, b) => getCount(b) - getCount(a)
const getCount = option => option.value === 'unknown' ? -1 : option.count

const formatOption = ({ worksUrisPerValue, facetsEntitiesBasicInfo }) => value => {
  return {
    value,
    image: facetsEntitiesBasicInfo[value]?.image?.url,
    text: facetsEntitiesBasicInfo[value]?.label || value,
    count: worksUrisPerValue[value].length,
    worksUris: worksUrisPerValue[value],
  }
}

export async function getInventoryView (type: 'group' | 'shelf' | 'user', doc: CouchDoc)
export async function getInventoryView (type: 'without-shelf')
export async function getInventoryView (type: string, doc?: CouchDoc) {
  let params
  if (type === 'without-shelf') {
    params = { user: app.user.id, 'without-shelf': true }
  } else {
    params = { [type]: doc._id }
  }
  return preq.get(API.items.inventoryView(params))
}

export function getFilteredItemsIds ({ intersectionWorkUris, itemsByDate, workUriItemsMap, textFilterItemsIds }) {
  let itemsIds
  if (intersectionWorkUris == null) {
    // Default to showing the latest items
    itemsIds = itemsByDate
  } else if (intersectionWorkUris.length === 0) {
    itemsIds = []
  } else {
    const worksItems = pick(workUriItemsMap, intersectionWorkUris)
    // Deduplicate as editions with several P629 values might have generated duplicates
    itemsIds = uniq(Object.values(worksItems).flat())
  }
  if (textFilterItemsIds != null) {
    itemsIds = intersection(itemsIds, textFilterItemsIds)
  }
  return itemsIds
}

export function resetPagination (itemsIds) {
  const items = []
  const shelvesByIds = {}
  const remainingItems = clone(itemsIds)
  let fetching
  const pagination = {
    items,
    total: itemsIds.length,
    shelvesByIds,
    allowMore: true,
    hasMore: () => {
      return remainingItems.length > 0
    },
    fetchMore: async () => {
      if (fetching) return
      fetching = true
      const batch = remainingItems.splice(0, 20)
      if (batch.length > 0) {
        await app.request('items:getByIds', { ids: batch, items })
      }
      pagination.items = items
      fetching = false
    },
  }
  return pagination
}

export function getInventoryDisplayStore (isMainUser) {
  if (isMainUser) {
    return getLocalStorageStore('mainUserInventoryDisplay', 'table')
  } else {
    return getLocalStorageStore('inventoryDisplay', 'cascade')
  }
}
