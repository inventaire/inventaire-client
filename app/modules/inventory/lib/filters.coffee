module.exports =
  initialize: (app)->

    Items.filtered = new FilteredCollection Items
    Items.personal.filtered = new FilteredCollection Items.personal
    Items.friends.filtered = new FilteredCollection Items.friends
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      'filter:inventory:owner': filterInventoryByOwner
      'filter:visibility': filterVisibilityBy
      'filter:visibility:reset': resetFilters

visibilityFilters =
  'private': {'listing':'private'}
  'friends': {'listing':'friends'}
  'public': {'listing':'public'}

filterVisibilityBy = (audience)->
  Items.personal.filtered.resetFilters()
  .filterBy audience, visibilityFilters[audience]

resetFilters = ->
  Items.personal.filtered.resetFilters()

filterInventoryByOwner = (collection, owner)->
  collection.resetFilters()
  collection.filterBy 'owner', (model)-> model.get('owner') is owner