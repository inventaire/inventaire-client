isLoggedIn = require './lib/is_logged_in'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.ItemView.extend
  selectIfInEditMode: ->
    if @editMode
      # somehow seems to need a delay
      setTimeout @select.bind(@), 100

  onKeyup: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideEditMode()
      when 'enter'
        if e.ctrlKey then @save()

  showEditMode: (e)->
    if isLoggedIn()
      # Clicking on the identifier should only open wikidata in another window
      if e?.target.className is 'identifier' then return

      @toggleEditMode true
      @triggerEditEvent()

  triggerEditEvent: ->

  hideEditMode: ->
    @toggleEditMode false
    @onHideEditMode()

  onHideEditMode: ->

  toggleEditMode: (bool)->
    @editMode = bool
    @lazyRender()
