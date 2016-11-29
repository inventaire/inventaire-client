isLoggedIn = require './lib/is_logged_in'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

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

  delete: ->
    action = => @_save null

    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n 'Are you sure you want to delete this statement?'
      action: action

  # To be define on the children and call @_save
  # save: ->

  _save: (newValue)->
    @model.saveValue newValue
    # target only this view
    .catch error_.Complete(".#{@cid} .has-alertbox")
    .catch @_catchAlert.bind(@)

    @hideEditMode()

  _catchAlert: (err)->
    # Making sure that we are in edit mode as it might have re-rendered
    # already before the error came back from the server
    @showEditMode()

    alert = => forms_.catchAlert @, err
    # Let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    setTimeout alert, 500
