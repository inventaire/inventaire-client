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
      app.layout.main.show new ItemCreationForm(params)
      # Remove the final add part so that hitting reload or previous
      # reloads the entity page instead of the creation form,
      # avoiding to create undesired item duplicates
      app.navigate pathname.replace(/\/add$/, '')
