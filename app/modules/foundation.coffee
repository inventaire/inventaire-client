module.exports = (module, app, Backbone, Marionette, $, _) ->

  app.commands.setHandlers
    'foundation:reload': ->
      # first called on account menu show
      $(document).foundation()
      app.vent.trigger 'foundation:reload'

    'modal:open': -> $('#modal').foundation('reveal', 'open')
    'modal:close': -> $('#modal').foundation('reveal', 'close')
    # commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()