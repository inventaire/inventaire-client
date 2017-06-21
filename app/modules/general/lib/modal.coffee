getActionKey = require 'lib/get_action_key'

module.exports = ->
  $body = $('body')
  $modalWrapper = $('#modalWrapper')
  $modal = $('#modal')
  $modalContent = $('#modalContent')
  $closeModal = $('#modal .close')

  modalOpen = (size, focusSelector, dark=false)->
    if size is 'large' then largeModal()
    else normalModal()

    openModal()

    if dark then $modalContent.addClass 'dark'
    else $modalContent.removeClass 'dark'

    setTimeout focusFirstTabElement, 200
    # Allow to pass a selector to which to re-focus once the modal closes
    if _.isNonEmptyString focusSelector then prepareRefocus focusSelector

  focusFirstTabElement = ->
    $firstTabElement = $modal.find('input, textarea, [tabindex="0"]').first().focus()
    if $firstTabElement.length > 0 then $firstTabElement.focus()
    else $modalWrapper.focus()

  lastOpen = 0
  openModal = ->
    lastOpen = _.now()
    if isOpened() then return
    $body.addClass 'openedModal'
    $modalWrapper.removeClass 'hidden'
    app.vent.trigger 'modal:opened'

  closeModal = ->
    # Ignore closing call happening less than 200ms after the last open call:
    # it's probably a view destroying itself and calling modal:close
    # while an other view requiring the modal to be opened just requested it
    if lastOpen > _.now() - 200 then return

    unless isOpened() then return
    $body.removeClass 'openedModal'
    $modalWrapper.addClass 'hidden'
    app.vent.trigger 'modal:closed'

  isOpened = -> $modalWrapper.hasClass('hidden') is false

  largeModal = -> $modal.addClass 'large'
  normalModal = -> $modal.removeClass 'large'

  # Close the modal:
  # - when clicking the 'close' button
  $closeModal.on 'click', closeModal
  # - when clicking out of the modal
  $modalWrapper.on 'click', (e)->
    { id } = e.target
    if id is 'modalWrapper' or id is 'modal' then closeModal()
  # - when pressing ESC
  $body.on 'keydown', (e)-> if getActionKey(e) is 'esc' then closeModal()

  app.commands.setHandlers
    'modal:open': modalOpen
    'modal:close': closeModal

prepareRefocus = (focusSelector)->
  _.log focusSelector, 'preparing re-focus'
  app.vent.once 'modal:closed', ->
    $(focusSelector).focus()
    _.log focusSelector, 're-focusing'
