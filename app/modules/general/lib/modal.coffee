getActionKey = require 'lib/get_action_key'

module.exports = ->
  $modal = $('#modal')
  $modalWrapper = $('#modalWrapper')
  $closeModal = $('#modal .close')

  modalOpen = (size, focusSelector)->
    if size is 'large' then largeModal()
    else normalModal()

    openModal()

    setTimeout focusFirstInput, 600
    # Allow to pass a selector to which to re-focus once the modal closes
    if _.isNonEmptyString focusSelector then prepareRefocus focusSelector

  focusFirstInput = ->
    $firstInput = $modal.find('input, textarea').first()
    if $firstInput.length > 0 then $firstInput.focus()
    # If the modal view has no input, focus the whole modal wrapper
    # to be able to listen to ESC key events
    else $modalWrapper.focus()

  openModal = ->
    if isOpened() then return
    $modalWrapper.removeClass 'hidden'
    app.vent.trigger 'modal:opened'

  closeModal = ->
    unless isOpened() then return
    $modalWrapper.addClass 'hidden'
    app.vent.trigger 'modal:closed'

  isOpened = -> $modalWrapper.hasClass('hidden') is false

  largeModal = -> $modal.addClass 'large'
  normalModal = -> $modal.removeClass 'large'

  # Close the modal:
  # - when clicking the 'close' button
  $closeModal.on 'click', closeModal
  # - when clicking out of the modal
  $modalWrapper.on 'click', (e)-> if e.target.id is 'modalWrapper' then closeModal()
  # - when pressing ESC
  $modalWrapper.on 'keydown', (e)-> if getActionKey(e) is 'esc' then closeModal()

  app.commands.setHandlers
    'modal:open': modalOpen
    'modal:close': closeModal

prepareRefocus = (focusSelector)->
  _.log focusSelector, 'preparing re-focus'
  app.vent.once 'modal:closed', ->
    $(focusSelector).focus()
    _.log focusSelector, 're-focusing'
