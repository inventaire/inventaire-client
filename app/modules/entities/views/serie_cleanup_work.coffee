getActionKey = require 'lib/get_action_key'
getLangsData = require 'modules/entities/lib/editor/get_langs_data'
SerieCleanupAuthors = require './serie_cleanup_authors'
SerieCleanupEditions = require './serie_cleanup_editions'

module.exports = Marionette.LayoutView.extend
  tagName: 'li'
  template: require './templates/serie_cleanup_work'
  className: ->
    classes = 'serie-cleanup-work'
    if @model.get('isPlaceholder') then classes += ' placeholder'
    return classes

  regions:
    authorsContainer: '.authorsContainer'
    editionsContainer: '.editionsContainer'

  ui:
    head: '.head'
    placeholderEditor: '.placeholderEditor'
    placeholderLabelEditor: '.placeholderEditor input'
    langSelector: '.langSelector'

  initialize: ->
    @lazyRender = _.LazyRender @, 100
    lazyLangSelectorUpdate = _.debounce @onOtherLangSelectorChange.bind(@), 500
    @listenTo app.vent, 'lang:local:change', lazyLangSelectorUpdate
    @listenTo app.vent, 'serie:cleanup:parts:change', @lazyRender

    { @allAuthorsUris } = @options

  serializeData: ->
    data = @model.toJSON()
    localLang = app.request 'lang:local:get'
    data.langs = getLangsData localLang, @model.get('labels')
    if @options.showPossibleOrdinals
      data.possibleOrdinals = @options.getPlaceholdersOrdinals()
    return data

  onRender: ->
    if @model.get 'isPlaceholder'
      @$el.attr 'tabindex', 0
      return

    { currentAuthorsUris, authorsSuggestionsUris } = @spreadAuthors()

    @authorsContainer.show new SerieCleanupAuthors {
      work: @model
      currentAuthorsUris,
      authorsSuggestionsUris
    }

    @editionsContainer.show new SerieCleanupEditions
      collection: @model.editions
      getWorksWithOrdinalList: @options.getWorksWithOrdinalList
      worksWithOrdinal: @options.worksWithOrdinal

  events:
    'change .ordinalSelector': 'updateOrdinal'
    'click .create': 'create'
    'click': 'showPlaceholderEditor'
    'keydown': 'onKeydown'
    'change .langSelector': 'propagateLangChange'

  updateOrdinal: (e)->
    { value } = e.currentTarget
    @model.setPropertyValue 'wdt:P1545', null, value

  showPlaceholderEditor: ->
    unless @model.get('isPlaceholder') then return
    unless @ui.placeholderEditor.hasClass 'hidden' then return
    @ui.head.addClass 'force-hidden'
    @ui.placeholderEditor.removeClass 'hidden'
    @$el.attr 'tabindex', null
    # Wait to avoid the enter event to be propagated as an enterClick to 'create'
    @setTimeout _.focusInput.bind(null, @ui.placeholderLabelEditor), 100

  hidePlaceholderEditor: ->
    @ui.head.removeClass 'force-hidden'
    @ui.placeholderEditor.addClass 'hidden'
    @$el.attr 'tabindex', 0
    @$el.focus()

  create: ->
    unless @model.get('isPlaceholder') then return
    lang = @ui.langSelector.val()
    label = @ui.placeholderLabelEditor.val()
    @model.setLabel lang, label
    @model.create()
    .then @replaceModel.bind(@)

  replaceModel: (newModel)->
    newModel.set 'ordinal', @model.get('ordinal')
    @model.collection.add newModel
    @model.collection.remove @model

  onKeydown: (e)->
    key = getActionKey e
    switch key
      when 'enter' then @showPlaceholderEditor()
      when 'esc' then @hidePlaceholderEditor()

  propagateLangChange: (e)->
    { value } = e.currentTarget
    app.vent.trigger 'lang:local:change', value

  onOtherLangSelectorChange: (value)->
    if @ui.placeholderEditor.hasClass 'hidden' then @ui.langSelector.val value

  spreadAuthors: ->
    currentAuthorsUris = @model.get('claims.wdt:P50') or []
    authorsSuggestionsUris = _.difference @allAuthorsUris, currentAuthorsUris
    return { currentAuthorsUris, authorsSuggestionsUris }
