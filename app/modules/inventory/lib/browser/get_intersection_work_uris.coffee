currentOwnerItemsByWork = null

module.exports = (worksTree, filters)->
  subsets = []
  for selectorTreeKey, selectedOptionKey of filters
    if selectedOptionKey?
      uris = getFilterWorksUris worksTree, selectorTreeKey, selectedOptionKey
      subsets.push uris
    else
      resetFilterData selectorTreeKey

  if subsets.length is 0 then return null

  intersectionWorkUris = _.intersection subsets...

  return intersectionWorkUris

getFilterWorksUris = (worksTree, selectorTreeKey, selectedOptionKey)->
  if selectorTreeKey is 'owner'
    currentOwnerItemsByWork = worksTree.owner[selectedOptionKey] or {}
    return Object.keys currentOwnerItemsByWork
  else
    return worksTree[selectorTreeKey][selectedOptionKey]

resetFilterData = (selectorTreeKey)->
  if selectorTreeKey is 'owner' then currentOwnerItemsByWork = null
