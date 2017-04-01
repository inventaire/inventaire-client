EditorCommons = require './editor_commons'
getBestLangValue = sharedLib('get_best_lang_value')(_)
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = EditorCommons.extend
  template: require './templates/title_editor'
  mainClassName: 'title-editor'
  initialize: ->
    { @creating } = @model
    { @lang } = app.user
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

  getValue: -> getBestLangValue(@lang, null, @model.get('labels')).value

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
    errSelector = ".#{@cid} .has-alertbox"

    unless _.isNonEmptyString value
      return forms_.bundleAlert @, "this value can't be empty", errSelector

    @editMode = false

    if value is @getValue()
      @lazyRender()
    else
      # re-render will be triggered by change:labels event listener
      @model.setLabel @lang, value
      .catch error_.Complete(errSelector)
      .catch (err)=>
        # Bring back the edit mode
        @editMode = true
        @lazyRender()
        # Wait for the view to have re-rendered to show the alert
        setTimeout forms_.catchAlert.bind(null, @, err), 400
