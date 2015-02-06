module.exports =
  initialize: (app)->

    Items.filtered = new FilteredCollection Items
    Items.filtered.paginated = new FilteredCollection Items.filtered

    Items.personal.filtered = new FilteredCollection Items.personal
    Items.friends.filtered = new FilteredCollection Items.friends
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      'filter:inventory:owner': filterInventoryByOwner
      'filter:inventory:reset': resetInventoryFilter
      'filter:visibility': filterVisibilityBy
      'filter:visibility:reset': resetFilters

    app.reqres.setHandlers
      'filter:range': filterRange

visibilityFilters =
  'private': {'listing':'private'}
  'friends': {'listing':'friends'}
  'public': {'listing':'public'}

filterVisibilityBy = (audience)->
  Items.personal.filtered.resetFilters()
  .filterBy audience, visibilityFilters[audience]

resetFilters = ->
  Items.personal.filtered.resetFilters()

resetInventoryFilter = (owner)->
  Items.filtered.resetFilters()

filterInventoryByOwner = (owner)->
  Items.filtered.resetFilters()
  Items.filtered.filterBy 'owner', (model)-> model.get('owner') is owner

filterRange = (start, end)->
  Items.filtered.paginated.removeFilter('range')
  Items.filtered.paginated.filterBy 'range', (model)->
    rank = Items.filtered.indexOf(model)
    return start <= rank < end

  before = start
  after = Items.filtered.length - end

  return [before, after]
