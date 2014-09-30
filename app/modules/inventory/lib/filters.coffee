module.exports =
  initialize: (app)->

    Items.personal.filtered = new FilteredCollection Items.personal
    Items.contacts.filtered = new FilteredCollection Items.contacts
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      # 'filter:inventory:owner': filterInventoryByOwner
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

textFilter = (text)->
  if text.length isnt 0
    filterExpr = new RegExp text, 'i'
    app.filteredItems.filterBy 'text', (model)-> model.matches filterExpr
  else
    app.filteredItems.removeFilter 'text'