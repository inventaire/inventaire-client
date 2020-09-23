getActionKey = require 'lib/get_action_key'
screen_ = require 'lib/screen'

module.exports = ->
  $body = $('body')
  $topbar = $('#top-bar')
  $modalWrapper = $('#modalWrapper')
  $modal = $('#modal')
  $modalContent = $('#modalContent')
  $closeModal = $('#modal .close')

  modalOpen = (size, focusSelector, dark = false)->
    switch size
      when 'large' then largeModal()
      when 'medium' then mediumModal()
      else normalModal()

    openModal()

    if dark then $modalContent.addClass 'dark'
    else $modalContent.removeClass 'dark'

    # Focusing is useful for devices with a keyboard, so that you can Tab your way through forms
    # but not for touch only devices
    if _.isMobile or screen_.isSmall(800)
      return
    else
      setTimeout focusFirstTabElement, 200
      # Allow to pass a selector to which to re-focus once the modal closes
      if _.isNonEmptyString focusSelector then prepareRefocus focusSelector

  focusFirstTabElement = ->
    $firstTabElement = $modal.find('input, textarea, [tabindex="0"]').first().focus()
    # Do not focus if the element is not visible as that makes the scroll jump
    if $firstTabElement.length > 0 and $firstTabElement.visible() then $firstTabElement.focus()
    else $modalWrapper.focus()

  lastOpen = 0
  openModal = ->
    lastOpen = _.now()
    if isOpened() then return

    # Prevent width diff jumps
    bodyWidthBefore = $body.width()
    $body.addClass 'openedModal'
    bodyWidthAfter = $body.width()
    widthDiff = bodyWidthAfter - bodyWidthBefore
    setWidthJumpPreventingRules "#{bodyWidthBefore}px", "#{widthDiff}px"

    $modalWrapper.removeClass 'hidden'
    app.vent.trigger 'modal:opened'

  closeModal = (goBack)->
    # Ignore closing call happening less than 200ms after the last open call:
    # it's probably a view destroying itself and calling modal:close
    # while an other view requiring the modal to be opened just requested it
    if lastOpen > _.now() - 200 then return

    unless isOpened() then return

    $body.removeClass 'openedModal'
    $modalWrapper.addClass 'hidden'

    # Remove width diff jumps preventing rules
    setWidthJumpPreventingRules '', ''

    navigateOnClose = app.layout.modal.currentView?.options.navigateOnClose

    # goBack is true only when additionnaly to closing the modal
    # no new layout is shown in the main layout: it thus make sense to go back
    if navigateOnClose and goBack
      # If opening the modal trigged a route change
      # closing it should bring back to the previous history state.
      app.execute 'history:back'

    app.vent.trigger 'modal:closed'

  exitModal = ->
    app.layout.modal.currentView?.onModalExit?()
    closeModal()

  setWidthJumpPreventingRules = (maxWidth, rightOffset)->
    $body.css 'max-width', maxWidth
    $topbar.css 'right', rightOffset

  isOpened = -> $modalWrapper.hasClass('hidden') is false

  largeModal = -> $modal.addClass('modal-large').removeClass 'modal-medium'
  mediumModal = -> $modal.removeClass('modal-large').addClass 'modal-medium'
  normalModal = -> $modal.removeClass('modal-large').removeClass 'modal-medium'

  # Close the modal:
  # - when clicking the 'close' button
  $closeModal.on 'click', exitModal
  # - when clicking out of the modal
  $modalWrapper.on 'click', (e)->
    { id } = e.target
    if id is 'modalWrapper' or id is 'modal' then exitModal()
  # - when pressing ESC
  $body.on 'keydown', (e)-> if getActionKey(e) is 'esc' then exitModal()

  modalHtml = (html)->
    $modalContent.html html
    modalOpen()

  app.commands.setHandlers
    'modal:open': modalOpen
    'modal:close': closeModal
    'modal:html': modalHtml

prepareRefocus = (focusSelector)->
  _.log focusSelector, 'preparing re-focus'
  app.vent.once 'modal:closed', ->
    $el = $(focusSelector)
    # Do not focus if the element is not visible as that makes the scroll jump
    if $el.visible() then $(focusSelector).focus()
    _.log focusSelector, 're-focusing'
