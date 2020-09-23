let currentOwnerItemsByWork = null;

export default function(worksTree, filters){
  const subsets = [];
  for (let selectorName in filters) {
    const selectedOptionKey = filters[selectorName];
    if (selectedOptionKey != null) {
      const uris = getFilterWorksUris(worksTree, selectorName, selectedOptionKey);
      subsets.push(uris);
    } else {
      resetFilterData(selectorName);
    }
  }

  if (subsets.length === 0) { return null; }

  const intersectionWorkUris = _.intersection(...Array.from(subsets || []));

  return intersectionWorkUris;
};

var getFilterWorksUris = function(worksTree, selectorName, selectedOptionKey){
  if (selectorName === 'owner') {
    currentOwnerItemsByWork = worksTree.owner[selectedOptionKey] || {};
    return Object.keys(currentOwnerItemsByWork);
  } else {
    return worksTree[selectorName][selectedOptionKey];
  }
};

var resetFilterData = function(selectorName){
  if (selectorName === 'owner') { return currentOwnerItemsByWork = null; }
};
