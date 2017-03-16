EditorCommons = require './editor_commons'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
inputSelector = '.string-value-input'

module.exports = EditorCommons.extend
  mainClassName: 'string-value-editor'
  template: require './templates/string_value_editor'

  ui:
    input: inputSelector

  initialize: ->
    @lazyRender = _.LazyRender @
    @focusTarget = 'input'
    @initEditModeState()

  serializeData: ->
    attrs = @model.toJSON()
    attrs.editMode = @editMode
    attrs.editable = true
    return attrs

  onRender: ->
    @focusOnRender()

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    # 'click .delete': 'delete'
    # Not setting a particular selector so that any keyup event on the element triggers the event
    'keyup': 'onKeyup'

  save: ->
    val = @ui.input.val()

    unless _.isNonEmptyString val
      err = error_.new "can't be empty", val
      err.selector = inputSelector
      return forms_.alert @, err

    # Ignore if we got the same value
    if val is @model.get('value') then return @hideEditMode()

    @_save val
