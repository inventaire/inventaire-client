{ partialData, clickEvents } = require './editor/lib/edition_creation'
availableLangList = require 'lib/available_lang_list'

module.exports = Marionette.CompositeView.extend
  className: 'editions-list'
  template: require './templates/editions_list'
  childViewContainer: 'ul'
  childView: require './edition_li'
  emptyView: require './no_edition'
  childViewOptions: ->
    itemToUpdate: @options.itemToUpdate
    onWorkLayout: @options.onWorkLayout

  behaviors:
    Loading: {}
    # Required by editionCreationParial
    AlertBox: {}
    PreventDefault: {}

  initialize: ->
    { @work } = @options

    # Start with user lang as default if there are editions in that language
    if app.user.lang in @getAvailableLangs()
      @filter = LangFilter app.user.lang
    @selectedLang = app.user.lang

    if @collection.length > 0
      # If the collection was populated before showing the view,
      # the collection is ready
      @onceCollectionReady()
    else
      # Else, wait for the collection models to arrive
      lateOnceCollectionReady = _.debounce @lateOnceCollectionReady.bind(@), 200
      @listenTo @collection, 'add', lateOnceCollectionReady

  ui:
    languageSelect: 'select.languageFilter'

  onceCollectionReady: ->
    userLangEditions = @collection.filter(LangFilter(app.user.lang))
    # If no editions can be found in the user language, display all
    if userLangEditions.length is 0 then @filterLanguage 'all'

  lateOnceCollectionReady: ->
    @onceCollectionReady()
    # re-rendering required so that the language selector
    # gets all the now available options
    @lazyRender()

  getAvailableLangs: ->
    langs = @collection.map (model)-> model.get 'lang'
    return _.uniq langs

  getAvailableLanguages: (selectedLang)->
    availableLangList @getAvailableLangs(), selectedLang

  serializeData: ->
    hasEditions: @collection.length > 0
    hasWork: @work?
    availableLanguages: @getAvailableLanguages @selectedLang
    editionCreationData: partialData @work
    header: @options.header or 'editions'

  events:
    'change .languageFilter': 'filterLanguageFromEvent'
    'click .edition-creation a': 'dispatchCreationEditionClickEvents'

  filter: (child)-> child.get('lang') is app.user.lang

  filterLanguageFromEvent: (e)-> @filterLanguage e.currentTarget.value

  filterLanguage: (lang)->
    if (lang is 'all') or (lang not in @getAvailableLangs())
      @filter = null
      @selectedLang = 'all'
    else
      @filter = LangFilter lang
      @selectedLang = lang

    @lazyRender()

  onRender: ->
    lang = @selectedLang or 'all'
    @ui.languageSelect.val lang

  dispatchCreationEditionClickEvents: (e)->
    { id } = e.currentTarget
    { itemToUpdate } = @options
    clickEvents[id]?({ view: @, @work, e, itemToUpdate })

LangFilter = (lang)-> (child)-> child.get('lang') is lang
