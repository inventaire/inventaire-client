import getActionKey from 'lib/get_action_key'
import screen_ from 'lib/screen'
import isMobile from 'lib/mobile_check'

export default function () {
  const $body = $('body')
  const $topbar = $('#top-bar')
  const $modalWrapper = $('#modalWrapper')
  const $modal = $('#modal')
  const $modalContent = $('#modalContent')
  const $closeModal = $('#modal .close')

  const modalOpen = function (size, focusSelector, dark = false) {
    switch (size) {
    case 'large': largeModal(); break
    case 'medium': mediumModal(); break
    default: normalModal()
    }

    openModal()

    if (dark) {
      $modalContent.addClass('dark')
    } else { $modalContent.removeClass('dark') }

    // Focusing is useful for devices with a keyboard, so that you can Tab your way through forms
    // but not for touch only devices
    if (isMobile || screen_.isSmall(800)) {

    } else {
      setTimeout(focusFirstTabElement, 200)
      // Allow to pass a selector to which to re-focus once the modal closes
      if (_.isNonEmptyString(focusSelector)) { return prepareRefocus(focusSelector) }
    }
  }

  const focusFirstTabElement = function () {
    const $firstTabElement = $modal.find('input, textarea, [tabindex="0"]').first().focus()
    // Do not focus if the element is not visible as that makes the scroll jump
    if (($firstTabElement.length > 0) && $firstTabElement.visible()) {
      return $firstTabElement.focus()
    } else { return $modalWrapper.focus() }
  }

  let lastOpen = 0
  const openModal = function () {
    lastOpen = _.now()
    if (isOpened()) return

    // Prevent width diff jumps
    const bodyWidthBefore = $body.width()
    $body.addClass('openedModal')
    const bodyWidthAfter = $body.width()
    const widthDiff = bodyWidthAfter - bodyWidthBefore
    setWidthJumpPreventingRules(`${bodyWidthBefore}px`, `${widthDiff}px`)

    $modalWrapper.removeClass('hidden')
    return app.vent.trigger('modal:opened')
  }

  const closeModal = function (goBack) {
    // Ignore closing call happening less than 200ms after the last open call:
    // it's probably a view destroying itself and calling modal:close
    // while an other view requiring the modal to be opened just requested it
    if (lastOpen > (_.now() - 200)) return

    if (!isOpened()) return

    $body.removeClass('openedModal')
    $modalWrapper.addClass('hidden')

    // Remove width diff jumps preventing rules
    setWidthJumpPreventingRules('', '')

    const navigateOnClose = app.layout.modal.currentView?.options.navigateOnClose

    // goBack is true only when additionnaly to closing the modal
    // no new layout is shown in the main layout: it thus make sense to go back
    if (navigateOnClose && goBack) {
      // If opening the modal trigged a route change
      // closing it should bring back to the previous history state.
      app.execute('history:back')
    }

    return app.vent.trigger('modal:closed')
  }

  const exitModal = function () {
    app.layout.modal.currentView?.onModalExit?.()
    return closeModal()
  }

  const setWidthJumpPreventingRules = function (maxWidth, rightOffset) {
    $body.css('max-width', maxWidth)
    return $topbar.css('right', rightOffset)
  }

  const isOpened = () => $modalWrapper.hasClass('hidden') === false

  const largeModal = () => $modal.addClass('modal-large').removeClass('modal-medium')
  const mediumModal = () => $modal.removeClass('modal-large').addClass('modal-medium')
  const normalModal = () => $modal.removeClass('modal-large').removeClass('modal-medium')

  // Close the modal:
  // - when clicking the 'close' button
  $closeModal.on('click', exitModal)
  // - when clicking out of the modal
  $modalWrapper.on('click', e => {
    const { id } = e.target
    if ((id === 'modalWrapper') || (id === 'modal')) exitModal()
  })
  // - when pressing ESC
  $body.on('keydown', e => {
    if (getActionKey(e) === 'esc') exitModal()
  })

  const modalHtml = function (html) {
    $modalContent.html(html)
    modalOpen()
  }

  app.commands.setHandlers({
    'modal:open': modalOpen,
    'modal:close': closeModal,
    'modal:html': modalHtml
  })
};

const prepareRefocus = function (focusSelector) {
  _.log(focusSelector, 'preparing re-focus')
  app.vent.once('modal:closed', () => {
    const $el = $(focusSelector)
    // Do not focus if the element is not visible as that makes the scroll jump
    if ($el.visible()) { $(focusSelector).focus() }
    _.log(focusSelector, 're-focusing')
  })
}
