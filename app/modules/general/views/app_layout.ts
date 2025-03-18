import { debounce } from 'underscore'
import app from '#app/app'
import assert_ from '#app/lib/assert_types'
import { viewportIsSmall } from '#app/lib/screen'
import Dropdown from '#behaviors/dropdown'
import General from '#behaviors/general'
import PreventDefault from '#behaviors/prevent_default'
import initDocumentLang from '../lib/document_lang.ts'
import initFlashMessage from '../lib/flash_message.ts'
import initModal from '../lib/modal.ts'
import { showLoader } from '../lib/show_views.ts'
import waitForCheck from '../lib/wait_for_check.ts'
import ConfirmationModal from './confirmation_modal.ts'
import appLayoutTemplate from './templates/app_layout.hbs'

export default Marionette.View.extend({
  template: appLayoutTemplate,

  el: '#app',

  regions: {
    topBar: '#topBar',
    main: 'main',
    modal: '#modalContent',
    svelteModal: '#svelteModal',
  },

  ui: {
    topBar: '#topBar',
    flashMessage: '#flashMessage',
  },

  behaviors: {
    Dropdown,
    General,
    PreventDefault,
  },

  initialize () {
    this.render()

    app.commands.setHandlers({
      'show:loader': showLoader,
      'ask:confirmation': this.askConfirmation.bind(this),
      'history:back' (options) {
        // Go back only if going back means staying in the app
        // @ts-expect-error
        if (Backbone.history.last.length > 0) {
          window.history.back()
        } else {
          options?.fallback?.()
        }
      },
    })

    app.reqres.setHandlers({
      waitForCheck,
    })

    app.vent.on('overlay:shown', () => $('body').addClass('hasOverlay'))
    app.vent.on('overlay:hidden', () => $('body').removeClass('hasOverlay'))

    initDocumentLang(app.user.lang)

    initModal()
    initFlashMessage.call(this)
    // wait for the app to be initiated before listening to resize events
    // to avoid firing a meaningless event at initialization
    app.request('waitForNetwork').then(initWindowResizeEvents)

    $('body').on('click', app.vent.Trigger('body:click'))
  },

  async onRender () {
    // Late import to prevent calling the $user store before the app.user
    // and waiters are properly setup
    const { default: TopBar } = await import('#components/top_bar.svelte')
    this.showChildComponent('topBar', TopBar)
    app.execute('waiter:resolve', 'topbar')
  },

  askConfirmation (options) {
    const { action, formAction } = options
    assert_.function(action)
    if (formAction != null) assert_.function(formAction)
    this.showChildView('modal', new ConfirmationModal(options))
  },
})

const initWindowResizeEvents = function () {
  let previousScreenMode = viewportIsSmall()
  const resizeEnd = function () {
    const newScreenMode = viewportIsSmall()
    if (newScreenMode !== previousScreenMode) {
      previousScreenMode = newScreenMode
      app.vent.trigger('screen:mode:change')
    }
  }

  const resize = debounce(resizeEnd, 150)
  $(window).resize(resize)
}
