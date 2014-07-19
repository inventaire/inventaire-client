module.exports = (module, app, Backbone, Marionette, $, _) ->

  app.commands.setHandler 'foundation:reload', ->
    # first called on account menu show
    $(document).foundation()
    console.log 'foundation:reload'


  app.commands.setHandler 'modal:open', ->
    $('#modal').foundation('reveal', 'open')
  app.commands.setHandler 'modal:close', ->
    $('#modal').foundation('reveal', 'close')
    # next line is commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()