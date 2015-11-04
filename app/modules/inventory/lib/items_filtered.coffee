itemsFilters =
  filteredByEntityUri: (uri)->
    @filterBy 'entityUri', (model)->
      model.get('entity') is uri

module.exports = (baseCollection)->
  filteredCollection = new FilteredCollection baseCollection
  return _.extend filteredCollection, itemsFilters
