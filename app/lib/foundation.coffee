module.exports.initialize = (app)->
  app.commands.setHandlers
    'foundation:reload': _.debounce foundationReload, 50
    'modal:open': modalOpen
    'modal:close': modalClose

    # commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()


foundationReload = ->
  # first called on account menu show
  $(document).foundation()
  app.vent.trigger 'foundation:reload'

modalOpen = ->
  $('#modal').foundation('reveal', 'open')
  app.execute('foundation:reload')

modalClose = -> $('#modal').foundation('reveal', 'close')