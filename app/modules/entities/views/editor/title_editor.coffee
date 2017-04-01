EditorCommons = require './editor_commons'
getBestLangValue = sharedLib('get_best_lang_value')(_)
availableLangList = require 'lib/available_lang_list'
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
    langSelector: 'langSelector'

  serializeData: ->
    { value, lang } = @getValue()
    return {
      editMode: @editMode
      value: value
      disableDelete: true
      availableLangs: @getAvailableLangs lang
    }

  getValue: ->
    if @requestedLang
      value = @model.get('labels')[@requestedLang]
      return { value, lang: @requestedLang }
    else
      getBestLangValue @lang, null, @model.get('labels')

  getAvailableLangs: (selectedLang)->
    availableLangs = Object.keys @model.get('labels')
    { lang:userLang } = app.user
    unless userLang in availableLangs then availableLangs.push userLang
    return availableLangList availableLangs, selectedLang

  onShow: ->
    @listenTo @model, 'change:labels', @lazyRender

  onRender: -> @selectIfInEditMode()

  select: -> @ui.input.select()

  events:
    'click .edit, .title-value': 'showEditMode'
    'click .save': 'save'
    'click .cancel': 'hideEditMode'
    'keyup input': 'onKeyup'
    'change .langSelector': 'changeLabelLang'

  changeLabelLang: (e)->
    @requestedLang = e.currentTarget.value

    if @model.get('labels')[@requestedLang]?
      if @editMode then @editMode = false
    else
      @editMode = true

    @lazyRender()

  save: ->
    lang = @ui.langSelector.val()
    value = @ui.input.val()
    errSelector = ".#{@cid} .has-alertbox"

    unless _.isNonEmptyString value
      return forms_.bundleAlert @, "this value can't be empty", errSelector

    @editMode = false

    if value is @getValue()
      @lazyRender()
    else
      # re-render will be triggered by change:labels event listener
      @model.setLabel lang, value
      .catch error_.Complete(errSelector)
      .catch (err)=>
        # Bring back the edit mode
        @editMode = true
        @lazyRender()
        # Wait for the view to have re-rendered to show the alert
        setTimeout forms_.catchAlert.bind(null, @, err), 400
