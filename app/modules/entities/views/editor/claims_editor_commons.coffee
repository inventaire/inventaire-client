EditorCommons = require './editor_commons'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
properties = require 'modules/entities/lib/properties'

# Methods that can't be on editor_commons because ./labels_editor is structured differently:
# while property values are having an ad-hoc model created, labels just use their entity's
# label
module.exports = EditorCommons.extend
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

  resetValue: ->
    # In case an empty value was created to allow creating a new claim
    # but the action was cancelled
    # Known cases; 'delete', 'cancel' with no previous value saved
    if not @model.get('value')? then @model.destroy()

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
