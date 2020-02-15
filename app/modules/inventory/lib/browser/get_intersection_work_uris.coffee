currentOwnerItemsByWork = null

module.exports = (worksTree, filters)->
  subsets = []
  for selectorName, selectedOptionKey of filters
    if selectedOptionKey?
      uris = getFilterWorksUris worksTree, selectorName, selectedOptionKey
      subsets.push uris
    else
      resetFilterData selectorName

  if subsets.length is 0 then return null

  intersectionWorkUris = _.intersection subsets...

  return intersectionWorkUris

getFilterWorksUris = (worksTree, selectorName, selectedOptionKey)->
  if selectorName is 'owner'
    currentOwnerItemsByWork = worksTree.owner[selectedOptionKey] or {}
    return Object.keys currentOwnerItemsByWork
  else
    return worksTree[selectorName][selectedOptionKey]

resetFilterData = (selectorName)->
  if selectorName is 'owner' then currentOwnerItemsByWork = null
