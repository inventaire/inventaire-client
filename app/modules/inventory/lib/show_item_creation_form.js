ItemCreationForm = require '../views/form/item_creation'
EditionsList = require 'modules/entities/views/editions_list'
error_ = require 'lib/error'

module.exports = (params)->
  { entity } = params
  unless entity? then throw new Error 'missing entity'

  { type } = entity
  unless type? then throw new Error 'missing entity type'

  pathname = entity.get('pathname') + '/add'
  unless app.request 'require:loggedIn', pathname then return

  # It is not possible anymore to create items from works
  if type is 'work' then return showEditionPicker entity

  # Close the modal in case it was opened by showEditionPicker
  app.execute 'modal:close'

  if type isnt 'edition' then throw new Error "invalid entity type: #{type}"

  uri = entity.get 'uri'

  app.layout.main.show new ItemCreationForm params
  app.navigate pathname

showEditionPicker = (work)->
  work.fetchSubEntities()
  .then ->
    app.layout.modal.show new EditionsList
      collection: work.editions
      work: work
      header: 'select an edition'
    app.execute 'modal:open', 'large'
