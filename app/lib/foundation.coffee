module.exports.initialize = (app)->
  app.commands.setHandlers
    'foundation:reload': ->
      # first called on account menu show
      $(document).foundation()
      app.vent.trigger 'foundation:reload'

    'modal:open': ->
      $('#modal').foundation('reveal', 'open')
      app.execute('foundation:reload')
    'modal:close': -> $('#modal').foundation('reveal', 'close')
    # commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()