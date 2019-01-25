# General events to be shared between the app_layout and modal
# given app_layout can't catch modal events
moveCaretToEnd = require 'modules/general/lib/move_caret_to_end'
enterClick = require 'modules/general/lib/enter_click'
preventFormSubmit = require 'modules/general/lib/prevent_form_submit'
showViews = require '../lib/show_views'

execute = (commandName)-> (e)->
  if _.isOpenedOutside(e) then return
  app.execute commandName
  e.stopPropagation()

module.exports = Marionette.Behavior.extend
  events:
    'submit form': preventFormSubmit
    'focus textarea': moveCaretToEnd
    'keyup input.enterClick': enterClick.input
    'keyup textarea.ctrlEnterClick': enterClick.textarea
    'keyup a.button,a.enterClick,div.enterClick,a[tabindex=0]': enterClick.button
    'click a.back': -> window.history.back()
    'click .showHome': execute 'show:home'
    'click .showWelcome': execute 'show:welcome'
    'click .showLogin': execute 'show:login'
    'click .showInventory': execute 'show:inventory'
    'click a.entity-value, a.showEntity': 'showEntity'
    'click .signupRequest': execute 'show:signup:redirect'
    'click .loginRequest': execute 'show:login:redirect'

  showEntity: showViews.showEntity
