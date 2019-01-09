isLoggedIn = require './lib/is_logged_in'
getActionKey = require 'lib/get_action_key'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
properties = require 'modules/entities/lib/properties'

module.exports = Marionette.ItemView.extend
  # @cid class required by _save error_.Complete
  className: -> "value-editor-commons #{@mainClassName} #{@cid}"
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

  initEditModeState: ->
    # If the value is null, start in edit mode
    @editMode = not @model.get('value')?

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    { property, value } = attrs
    if value? and properties[property].editorType is 'image'
      attrs.imageUrl = "/img/entities/#{value}"
    return attrs

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
    @onToggleEditMode?()
    @lazyRender()

  delete: ->
    # Do not ask for confirmation when there was no previously existing statement
    if @model.get('value') is null then return @_save null

    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'Are you sure you want to delete this statement?'
      action: => @_save null

  # To be define on the children and call @_save
  # save: ->

  _save: (newValue)->
    @_bareSave newValue
    # target only this view
    .catch error_.Complete(".#{@cid} .has-alertbox")
    .catch @_catchAlert.bind(@)

  _bareSave: (newValue)->
    uri = @model.entity.get('uri')

    promise = @model.saveValue newValue
      .catch enrichError(uri)

    # Should be triggered after @model.saveValue so that a defined value
    # doesn't appear null for @hideEditMode
    @hideEditMode()

    return promise
    .catch (err)=>
      # Re-display the edit mode to show the alert
      @showEditMode()
      Promise.resolve()
      # Throw the error after the view lazy re-rendered
      .delay 250
      .then -> throw err

  _catchAlert: (err)->
    # Making sure that we are in edit mode as it might have re-rendered
    # already before the error came back from the server
    @showEditMode()

    alert = => forms_.catchAlert @, err
    # Let the time to the changes and rollbacks to trigger lazy re-render
    # before trying to show the alert message
    @setTimeout alert, 500

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

enrichError = (uri)-> (err)->
  if err.responseJSON?.status_verbose is 'this property value is already used'
    { entity: duplicateUri } = err.responseJSON.context
    reportPossibleDuplicate uri, duplicateUri
    formatDuplicateErr err, uri, duplicateUri

  throw err

reportPossibleDuplicate = (uri, duplicateUri)->
  app.request 'post:feedback',
    subject: "[Possible duplicate] #{uri} / #{duplicateUri}"
    uris: [ uri, duplicateUri ]

formatDuplicateErr = (err, uri, duplicateUri)->
  alreadyExist = _.i18n 'this value is already used'
  link = "<a href='/entity/#{duplicateUri}' class='showEntity'>#{duplicateUri}</a>"
  reported = _.i18n 'the issue was reported'
  err.responseJSON.status_verbose = "#{alreadyExist}: #{link} (#{reported})"
  err.i18n = false
