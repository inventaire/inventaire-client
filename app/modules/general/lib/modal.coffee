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
    $modal.find('input, textarea').first().focus()

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

  $closeModal.on 'click', closeModal
  $modalWrapper.on 'click', (e)->
    # Only close the modal when the click is outside the modal content
    # and thus as the #modalWrapper as direct target
    if e.target.id is 'modalWrapper' then closeModal()

  app.commands.setHandlers
    'modal:open': modalOpen
    'modal:close': closeModal

prepareRefocus = (focusSelector)->
  _.log focusSelector, 'preparing re-focus'
  app.vent.once 'modal:closed', ->
    $(focusSelector).focus()
    _.log focusSelector, 're-focusing'
