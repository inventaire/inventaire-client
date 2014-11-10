module.exports =
  initialize: (app)->

    Items.personal.filtered = new FilteredCollection Items.personal
    Items.friends.filtered = new FilteredCollection Items.friends
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      'filter:inventory:owner': filterInventoryByOwner
      'filter:visibility': filterVisibilityBy
      'filter:visibility:reset': resetFilters

filterVisibilityBy = (audience)->
  resetFilters()
  Items.personal.filtered.filterBy audience, visibilityFilters[audience]

visibilityFilters =
  'private': {'listing':'private'}
  'friends': {'listing':'friends'}
  'public': {'listing':'public'}

resetFilters = ->
  Items.personal.filtered.resetFilters()

filterInventoryByOwner = (collection, owner)->
  collection.filterBy 'owner', (model)-> model.get('owner') is owner