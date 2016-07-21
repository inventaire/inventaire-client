EditorCommons = require './editor_commons'
getBestLangValue = require '../../lib/get_best_lang_value'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = EditorCommons.extend
  template: require './templates/title_editor'
  className: -> "#{@cid} title-editor"
  initialize: ->
    { @creating } = @model
    { @lang } = app.user
    @editMode = if @creating then true else false
    @lazyRender = _.LazyRender @

  behaviors:
    AlertBox: {}

  ui:
    input: 'input'

  serializeData: ->
    editMode: @editMode
    value: @getValue()
    disableDelete: true

  getValue: -> getBestLangValue @lang, null, @model.get('labels')

  onShow: ->
    @listenTo @model, 'change:labels', @lazyRender

  onRender: -> @selectIfInEditMode()

  select: -> @ui.input.select()

  events:
    'click .edit, .title-value': 'showEditMode'
    'click .save': 'save'
    'click .cancel': 'hideEditMode'
    'keyup input': 'onKeyup'

  save: ->
    value = @ui.input.val()
    unless _.isNonEmptyString value
      return forms_.bundleAlert @, "this value can't be empty", ".#{@cid} .has-alertbox"

    @editMode = false
    @model.setLabel @lang, value
