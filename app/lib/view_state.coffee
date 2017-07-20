# A skip/catch skip pattern for async view actions
# typically, actions behind a data waiter.
# Allows to stop all actions made obsolete, particullary justified
# when there are potentially a lot of them or costly ones

# Could be added to Marionette.View prototype if shown broadly useful

# See also Marionette.View::ifViewIsIntact in app/lib/global_libs_extender

module.exports =
  CheckViewState: (view, label='')->
    check = (data)->
      if view.isDestroyed
        # throw an error to be skip the next actions
        # that were requiring a view
        err = new Error "#{label} view was destroyed: actions stopped"
        err.destroyed_view = true
        throw err
      else
        return data

  catchDestroyedView: (err)->
    if err.destroyed_view
      _.warn err.message
      return
    else
      throw err
