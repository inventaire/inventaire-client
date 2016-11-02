ItemCreationForm = require '../views/form/item_creation'

module.exports = (params)->
  { work, preventDupplicates } = params
  unless work? then throw new Error 'missing work'
  uri = work.get 'uri'

  # 'waitForItems' is required by item:main:user:instances
  if preventDupplicates then waiter = app.Request 'waitForItems'
  else waiter = _.preq.resolve

  waiter()
  .then ->
    if preventDupplicates
      existingInstances = app.request 'item:main:user:instances', uri
      if existingInstances.length > 0
        _.log existingInstances, 'existing instances'
        # Show the work instead to display the number of existing instances
        # and avoid creating a dupplicate
        app.execute 'show:entity', uri
        return

    workPathname = params.work.get 'pathname'
    pathname = "#{workPathname}/add"

    if app.request 'require:loggedIn', pathname
      app.layout.main.show new ItemCreationForm(params)
      # Remove the final add part so that hitting reload or previous
      # reloads the work page instead of the creation form,
      # avoiding to create undesired item dupplicates
      app.navigate pathname.replace(/\/add$/, '')
