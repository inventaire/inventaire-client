# General events to be shared between the app_layout and modal
# given app_layout can't catch modal events
moveCaretToEnd = require 'modules/general/lib/move_caret_to_end'
enterClick = require 'modules/general/lib/enter_click'
showViews = require '../lib/show_views'

module.exports = Marionette.Behavior.extend
  events:
    'submit form': (e)-> e.preventDefault()
    'focus textarea': moveCaretToEnd
    'keyup input.enterClick': enterClick.input
    'keyup textarea.ctrlEnterClick': enterClick.textarea
    'keyup a.button,a.enterClick,div.enterClick,a[tabindex=0]': enterClick.button
    'click a.back': -> window.history.back()
    'click .showHome': (e)->
        unless _.isOpenedOutside(e) then app.execute 'show:home'
    'click .showWelcome': -> app.execute 'show:welcome'
    'click .showLogin': -> app.execute 'show:login'
    'click .showInventory': -> app.execute 'show:inventory'
    'click a.entity-value, a.showEntity': 'showEntity'
    'click .signupRequest': -> app.execute 'show:signup:redirect'
    'click .loginRequest': -> app.execute 'show:login:redirect'

  showEntity: showViews.showEntity
