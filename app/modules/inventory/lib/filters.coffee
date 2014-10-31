module.exports =
  initialize: (app)->

    Items.personal.filtered = new FilteredCollection Items.personal
    Items.contacts.filtered = new FilteredCollection Items.contacts
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      'filter:inventory:owner': filterInventoryByOwner
      'filter:visibility': filterVisibilityBy
      'filter:visibility:reset': resetFilters
      'textFilter': textFilter

filterVisibilityBy = (audience)->
  resetFilters()
  Items.personal.filtered.filterBy audience, visibilityFilters[audience]

visibilityFilters =
  'private': {'listing':'private'}
  'contacts': {'listing':'contacts'}
  'public': {'listing':'public'}

resetFilters = ->
  Items.personal.filtered.resetFilters()

textFilter = (collection, text)->
  if text.length isnt 0
    filterExpr = new RegExp text, 'i'
    collection.filterBy 'text', (model)-> model.matches filterExpr
  else
    collection.removeFilter 'text'

filterInventoryByOwner = (collection, owner)->
  collection.filterBy 'owner', (model)-> model.get('owner') is owner