ClaimsEditorCommons = require './claims_editor_commons'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
inputSelector = '.string-value-input'
{ initEditionTitleTip, tipOnKeyup, tipOnRender } = require './lib/title_tip'

module.exports = ClaimsEditorCommons.extend
  mainClassName: 'string-value-editor'
  template: require './templates/string_value_editor'

  ui:
    input: 'input'
    tip: '.tip'

  initialize: ->
    @lazyRender = _.LazyRender @
    @focusTarget = 'input'
    @initEditModeState()
    initEditionTitleTip.call @, @model.entity, @model.get('property')

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    attrs.editable = true
    return attrs

  onRender: ->
    @focusOnRender()
    tipOnRender.call @

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    # Not setting a particular selector so that
    # any keyup event on the element triggers the event
    'keyup': 'onKeyupCustom'

  save: ->
    val = @ui.input.val().trim()

    unless _.isNonEmptyString val
      err = error_.new "can't be empty", val
      err.selector = inputSelector
      return forms_.alert @, err

    # Ignore if we got the same value
    if val is @model.get('value') then return @hideEditMode()

    @_save val

  onKeyupCustom: (e)->
    @onKeyup e
    tipOnKeyup.call @, e
