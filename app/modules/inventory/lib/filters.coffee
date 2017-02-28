itemsFiltered = require './items_filtered'

module.exports = (app)->
  { items } = app

  items.filtered = itemsFiltered items

  filterItemsByText = (text, reset)->
    items.filtered.filterByText text, reset

  # includeTransaction = (transaction)->
  #   items.filtered.removeFilter "exclude:#{transaction}"

  # excludeTransaction = (transaction)->
  #   items.filtered.filterBy "exclude:#{transaction}", (item)->
  #     item.get('transaction') isnt transaction

  singleFilterReady = (filter)->
    filters = items.filtered.getFilters()
    return filters.length is 1 and filters[0] is filter

  app.commands.setHandlers
    'filter:items:byText': filterItemsByText
    # 'filter:inventory:transaction:include': includeTransaction
    # 'filter:inventory:transaction:exclude': excludeTransaction
