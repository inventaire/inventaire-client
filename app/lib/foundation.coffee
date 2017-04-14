module.exports.initialize = (app)->
  app.commands.setHandlers
    'foundation:reload': _.debounce foundationReload, 50
    'modal:open': modalOpen
    'modal:close': modalClose
    'foundation:joyride:start': startJoyride

  # Foundation moves the #modalContent region in its own wrapper div
  # so we need to recover the desired events manually
  $('.close-reveal-modal').on 'click', app.vent.Trigger('modal:closed')

foundationReload = (options)->
  # first called on account menu show
  $(document).foundation options
  app.vent.trigger 'foundation:reload'

modalOpen = (size, focusSelector)->
  if size is 'large' then largeModal()
  else normalModal()

  unless isOpened() then $('#modal').foundation 'reveal', 'open'

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

modalClose = -> if isOpened() then $('#modal').foundation 'reveal', 'close'

largeModal = -> $('#modal').addClass 'large'
normalModal = -> $('#modal').removeClass 'large'

startJoyride = (options)->
  $(document).foundation(options).foundation 'joyride', 'start'

isOpened = -> $('#modal').css('visibility') is 'visible'
