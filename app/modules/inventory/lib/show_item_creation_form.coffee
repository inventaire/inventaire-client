ItemCreationForm = require '../views/form/item_creation'

module.exports = (params)->
  # Using the general domination of entity instead of work
  # as one might want to add an edition or a whole serie etc
  { entity, preventduplicates } = params
  unless entity? then throw new Error 'missing entity'
  uri = entity.get 'uri'

  if preventduplicates
    waiter = app.request 'items:fetchByUserIdAndEntity', app.user.id, uri
  else
    waiter = _.preq.resolved

  waiter
  .then ->
    if preventduplicates
      existingInstances = app.request 'item:main:user:instances', uri
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
    # copying the title for convinience
    # as it is used to display and find the item from search
    title: entity.get 'label'
    entity: entity.get 'uri'
    transaction: guessTransaction params
    listing: app.request 'last:listing:get'

  unless attrs.entity? and attrs.title?
    throw error_.new 'missing uri or title at item creation from entity', attrs

  return app.request 'item:create', attrs

guessTransaction = (params)->
  transaction = params.transaction or app.request('last:transaction:get')
  app.execute 'last:transaction:set', transaction
  return transaction
