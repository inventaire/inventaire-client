wdLang = require 'wikidata-lang'

module.exports = Marionette.CompositeView.extend
  template: require './templates/editions_list'
  childViewContainer: 'ul'
  childView: require './edition_layout'

  initialize: ->
    @lazyRender = _.LazyRender @, 50

    # Start with user lang as default if there are editions in that language
    if app.user.lang in @getAvailableLangs()
      @filter = LangFilter app.user.lang
    @selectedLang = app.user.lang

    if @collection.length > 0
      # If the collection was populated before showing the view, the cpmmection is ready
      @onceCollectionReady()
    else
      # Else, wait for the collection models to arrive
      onceCollectionReady = _.debounce @onceCollectionReady.bind(@), 100
      @listenTo @collection, 'add', onceCollectionReady

  ui:
    languageSelect: 'select.languageFilter'

  onceCollectionReady: ->
    userLangEditions = @collection.filter(LangFilter(app.user.lang))
    # If no editions can be found in the user language, display all
    if userLangEditions.length is 0 then @filterLanguage 'all'
    # re-rendering required so that the language selector gets all the now available options
    @lazyRender()

  getAvailableLangs: ->
    langs = @collection.map (model)-> model.get 'lang'
    return _.uniq langs

  getAvailableLanguages: (selectedLang)->
    @getAvailableLangs()
    .map (lang)->
      langObj = _.clone wdLang.byCode[lang]
      if langObj.code is selectedLang then langObj.selected = true
      return langObj

  serializeData: ->
    availableLanguages: @getAvailableLanguages @selectedLang

  events:
    'change .languageFilter': 'filterLanguageFromEvent'

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

LangFilter = (lang)-> (child)-> child.get('lang') is lang
