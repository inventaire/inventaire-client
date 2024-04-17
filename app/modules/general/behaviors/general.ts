import app from '#app/app'
// General events to be shared between the app_layout and modal
// given app_layout can't catch modal events
import { isOpenedOutside } from '#app/lib/utils'
import enterClick from '#general/lib/enter_click'
import preventFormSubmit from '#general/lib/prevent_form_submit'
import showViews from '../lib/show_views.ts'

const execute = commandName => function (e) {
  if (isOpenedOutside(e)) return
  app.execute(commandName)
  e.stopPropagation()
}

// @ts-expect-error
export default Marionette.Behavior.extend({
  events: {
    'submit form': preventFormSubmit,
    'keyup input.enterClick': enterClick.input,
    'keyup textarea.ctrlEnterClick': enterClick.textarea,
    'keyup a.button,a.enterClick,div.enterClick,a[tabindex=0]': enterClick.button,
    'click a.back' () { window.history.back() },
    'click .showHome': execute('show:home'),
    'click .showWelcome': execute('show:welcome'),
    'click .showLogin': execute('show:login'),
    'click .showInventory': execute('show:inventory'),
    'click .signupRequest': execute('show:signup:redirect'),
    'click .loginRequest': execute('show:login:redirect'),
    'click a.entity-value, a.showEntity': showViews.showEntity,
    'click a.showEntityEdit': showViews.showEntityEdit,
    'click a.showEntityCleanup': showViews.showEntityCleanup,
    'click a.showEntityHistory': showViews.showEntityHistory,
  },
})
