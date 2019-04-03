isLoggedIn = require './lib/is_logged_in'
getActionKey = require 'lib/get_action_key'
error_ = require 'lib/error'

module.exports = Marionette.ItemView.extend
  className: -> "value-editor-commons #{@mainClassName}"
  selectIfInEditMode: ->
    if @editMode
      # somehow seems to need a delay
      @setTimeout @select.bind(@), 100

  onKeyup: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideEditMode()
      when 'enter'
        if e.ctrlKey then @save()

  showEditMode: (e)->
    unless isLoggedIn() then return

    # Clicking on the identifier should only open wikidata in another window
    if e?.target.className is 'identifier' then return

    @toggleEditMode true
    @triggerEditEvent()

  triggerEditEvent: ->

  hideEditMode: ->
    @toggleEditMode false
    @resetValue()

  resetValue: ->

  toggleEditMode: (bool)->
    @editMode = bool
    @onToggleEditMode?()
    @lazyRender()

  # Focus an element on render
  # Requires to set a focusTarget and the corresponding UI element's name
  focusOnRender: ->
    unless @editMode then return

    focus = =>
      $el = @ui[@focusTarget]
      # Debug: run the linter to see if a view defines its ui elements twice
      unless $el
        uis = Object.keys @ui
        throw error_.new "@ui[@focusTarget] isn't defined", { uis, selector: @focusTarget }
      if $el[0].tagName is 'INPUT' then $el.select()
      else $el.focus()

    # Somehow required to let the time to thing to get in place
    @setTimeout focus, 200
