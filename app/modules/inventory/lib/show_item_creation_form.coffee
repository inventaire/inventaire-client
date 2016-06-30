ItemCreationForm = require '../views/form/item_creation'

module.exports = (params)->
  { entity, preventDupplicates } = params
  unless entity? then throw new Error 'missing entity'
  uri = entity.get 'uri'

  # 'waitForItems' is required by item:main:user:instances
  if preventDupplicates then waiter = app.Request 'waitForItems'
  else waiter = _.preq.resolve

  waiter()
  .then ->
    if preventDupplicates
      existingInstances = app.request 'item:main:user:instances', uri
      if existingInstances.length > 0
        _.log existingInstances, 'existing instances'
        # Show the entity instead to display the number of existing instances
        # and avoid creating a dupplicate
        app.execute 'show:entity', uri
        return

    entityPathname = params.entity.get 'pathname'
    pathname = "#{entityPathname}/add"

    if app.request 'require:loggedIn', pathname
      app.layout.main.show new ItemCreationForm(params)
      # Remove the final add part so that hitting reload or previous
      # reloads the entity page instead of the creation form,
      # avoiding to create undesired item dupplicates
      app.navigate pathname.replace(/\/add$/, '')
