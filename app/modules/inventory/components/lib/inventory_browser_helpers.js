import { getEntitiesAttributesByUris } from '#entities/lib/entities'
import error_ from '#lib/error'
import preq from '#lib/preq'
import { getShelves } from '#shelves/lib/shelves'
import { compact, difference, flatten, pluck, uniq, without } from 'underscore'

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

  const facetsEntitiesBasicInfo = await getBasicInfo(valuesUris)

  const facetsSelectors = getSelectorsOptions({ worksTree, facetsEntitiesBasicInfo })

  return {
    facets,
    facetsEntitiesBasicInfo,
    facetsSelectedValues,
    facetsSelectors,
  }
}

async function getBasicInfo (uris) {
  uris = uniq(uris)
  if (uris.length === 0) return []
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels', 'image' ],
    lang: app.user.lang
  })
  Object.values(entities).forEach(entity => {
    if (entity.labels == null) {
      error_.report('missing entity labels', { entity, uris })
      entity.label = ''
    } else {
      entity.label = Object.values(entity.labels)[0]
    }
  })
  return entities
}

const getSelectorsOptions = ({ worksTree, facetsEntitiesBasicInfo }) => {
  const facetsSelectors = {}
  for (const [ sectionName, worksUrisPerValue ] of Object.entries(worksTree)) {
    if (sectionName !== 'owner') {
      const facetSelector = {
        options: getOptions({ worksUrisPerValue, facetsEntitiesBasicInfo })
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

export async function getInventoryView (type, doc) {
  let params
  if (type === 'without-shelf') {
    params = { user: app.user.id, 'without-shelf': true }
  } else {
    params = { [type]: doc._id }
  }
  return preq.get(app.API.items.inventoryView(params))
}

export async function getNewItemsShelves (items, knownShelvesIds) {
  const shelvesIds = compact(pluck(items, 'shelves').flat())
  const newShelvesIds = difference(uniq(shelvesIds), knownShelvesIds)
  if (newShelvesIds.length > 0) return getShelves(newShelvesIds)
  else return {}
}
