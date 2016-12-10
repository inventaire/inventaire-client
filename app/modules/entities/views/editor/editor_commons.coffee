isLoggedIn = require './lib/is_logged_in'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = Marionette.ItemView.extend
  # @cid class required by _save error_.Complete
  className: -> "value-editor-commons #{@mainClassName} #{@cid}"
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
    # In case an empty value was created to allow creating a new claim
    # but the action was cancelled
    # Known cases; 'delete', 'cancel' with no previous value saved
    if not @model.get('value')? then @model.destroy()

  toggleEditMode: (bool)->
    @editMode = bool
    @lazyRender()

  delete: ->
    action = => @_save null

    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n 'Are you sure you want to delete this statement?'
      action: action

  # To be define on the children and call @_save
  # save: ->

  _save: (newValue)->
    promise = @model.saveValue newValue
    # target only this view
    .catch error_.Complete(".#{@cid} .has-alertbox")
    .catch @_catchAlert.bind(@)

    # Should be triggered after @model.saveValue so that a defined value
    # doesn't appear null for @hideEditMode
    @hideEditMode()

    return promise

  _catchAlert: (err)->
    # Making sure that we are in edit mode as it might have re-rendered
    # already before the error came back from the server
    @showEditMode()

    alert = => forms_.catchAlert @, err
    # Let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    setTimeout alert, 500

  # Focus an element on render
  # Requires to set a focusTarget and the corresponding UI element
  focusOnRender: ->
    if @editMode
      focus = =>
        $el = @ui[@focusTarget]
        if $el[0].tagName is 'INPUT' then $el.select()
        else $el.focus()
      # Somehow required to let the time to thing to get in place
      setTimeout focus, 200
