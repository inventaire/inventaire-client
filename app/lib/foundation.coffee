module.exports.initialize = (app)->
  app.commands.setHandlers
    'foundation:reload': _.debounce foundationReload, 50
    'modal:open': modalOpen
    'modal:close': modalClose
    'foundation:joyride:start': startJoyride

    # commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()

foundationReload = (options)->
  # first called on account menu show
  $(document).foundation options
  app.vent.trigger 'foundation:reload'

modalOpen = (size, focusSelector)->
  if size is 'large' then largeModal()
  else normalModal()

  $('#modal').foundation 'reveal', 'open'
  app.execute 'foundation:reload'
  setTimeout focusFirstInput, 600

  # allow to pass a selector to which to re-focus once the modal closes
  if _.isNonEmptyString focusSelector
    _.log focusSelector, 'preparing re-focus'
    focus = ->
      $(focusSelector).focus()
      _.log focusSelector, 're-focusing'
    $(document).once 'closed.fndtn.reveal', focus

focusFirstInput = ->
  $('#modal').find('input, textarea').first().focus()

modalClose = -> $('#modal').foundation 'reveal', 'close'

largeModal = -> $('#modal').addClass 'large'
normalModal = -> $('#modal').removeClass 'large'

startJoyride = (options)->
  $(document).foundation(options).foundation 'joyride', 'start'
