import { intersection } from 'underscore'
import { objectEntries } from '#app/lib/utils'

let currentOwnerItemsByWork = null

export function getIntersectionWorkUris ({ worksTree, facetsSelectedValues }) {
  const subsets = []
  for (const [ selectorName, selectedOptionKey ] of objectEntries(facetsSelectedValues)) {
    if (selectedOptionKey != null) {
      const uris = getFilterWorksUris(worksTree, selectorName, selectedOptionKey)
      subsets.push(uris)
    } else {
      resetFilterData(selectorName)
    }
  }

  if (subsets.length === 0) return null

  const intersectionWorkUris = intersection(...Array.from(subsets || []))

  return intersectionWorkUris
}

const getFilterWorksUris = function (worksTree, selectorName, selectedOptionKey) {
  if (selectorName === 'owner') {
    currentOwnerItemsByWork = worksTree.owner[selectedOptionKey] || {}
    return Object.keys(currentOwnerItemsByWork)
  } else {
    return worksTree[selectorName][selectedOptionKey]
  }
}

const resetFilterData = function (selectorName) {
  if (selectorName === 'owner') currentOwnerItemsByWork = null
}
