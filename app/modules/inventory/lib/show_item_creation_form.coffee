ItemCreationForm = require '../views/form/item_creation'
EditionsList = require 'modules/entities/views/editions_list'

module.exports = (params)->
  # Using the general domination of entity instead of work
  # as one might want to add an edition or a whole serie etc
  { entity, preventduplicates } = params
  unless entity? then throw new Error 'missing entity'

  { type } = entity
  unless type? then throw new Error 'missing entity type'

  # It is not possible anymore to create items from works
  if type is 'work' then return showEditionPicker entity

  # Close the modal in case it was opened by showEditionPicker
  app.execute 'modal:close'

  if type isnt 'edition' then throw new Error "invalid entity type: #{type}"

  uri = entity.get 'uri'

  if preventduplicates
    waiter = app.request 'item:main:user:instances', uri
  else
    waiter = _.preq.resolved

  waiter
  .then (existingInstances)->
    if preventduplicates
      if existingInstances.length > 0
        _.log existingInstances, 'existing instances'
        # Show the entity instead to display the number of existing instances
        # and avoid creating a duplicate
        app.execute 'show:entity', uri
        return

    entityPathname = params.entity.get 'pathname'
    pathname = "#{entityPathname}/add"

    if app.request 'require:loggedIn', pathname
      createItem entity, params
      .then (itemModel)->
        params.model = itemModel
        app.layout.main.show new ItemCreationForm(params)
        # Remove the final add part so that hitting reload or previous
        # reloads the entity page instead of the creation form,
        # avoiding to create undesired item duplicates
        app.navigate pathname.replace(/\/add$/, '')

createItem = (entity, params)->
  attrs =
    entity: entity.get 'uri'
    transaction: guessTransaction params
    listing: app.request 'last:listing:get'

  # We need to specify a lang for work entities
  if entity.type is 'work' then attrs.lang = guessLang entity

  unless attrs.entity? then throw error_.new 'missing uri', attrs

  return app.request 'item:create', attrs

guessTransaction = (params)->
  transaction = params.transaction or app.request('last:transaction:get')
  if transaction is 'null' then transaction = null
  app.execute 'last:transaction:set', transaction
  return transaction

guessLang = (entity)->
  { lang:userLang } = app.user
  [ labels, originalLang ] = entity.gets 'labels', 'originalLang'
  if labels[userLang]? then return userLang
  if labels[originalLang]? then return originalLang
  if labels.en? then return 'en'
  # If none of the above worked, return the first lang we find
  return Object.keys(labels)[0]

showEditionPicker = (work)->
  app.layout.modal.show new EditionsList
    collection: work.editions
    work: work
    header: 'select an edition'
  app.execute 'modal:open', 'large'
