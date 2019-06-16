AuthorInfobox = require './author_infobox'
{ startLoading } = require 'modules/general/plugins/behaviors'
EntitiesList = require './entities_list'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  template: require './templates/author_layout'
  className: ->
    # Default to wrapped mode in non standalone mode
    secondClass = ''
    if @options.standalone then secondClass = 'standalone'
    else if not @options.noAuthorWrap then secondClass = 'wrapped'
    prefix = @model.get 'prefix'
    return "authorLayout #{secondClass} entity-prefix-#{prefix}"

  attributes: ->
    # Used by deduplicate_layout
    'data-uri': @model.get('uri')

  behaviors:
    Loading: {}

  regions:
    infoboxRegion: '.authorInfobox'
    seriesRegion: '.series'
    worksRegion: '.works'
    articlesRegion: '.articles'
    mergeSuggestionsRegion: '.mergeSuggestions'

  initialize: ->
    { @standalone, @displayMergeSuggestions } = @options
    # Trigger fetchWorks only once the author is in view
    @$el.once 'inview', @fetchWorks.bind(@)

  events:
    'click .unwrap': 'unwrap'

  serializeData: ->
    standalone: @standalone
    displayMergeSuggestions: @displayMergeSuggestions

  fetchWorks: ->
    @worksShouldBeShown = true
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @model.initAuthorWorks refresh
    .then @ifViewIsIntact('showWorks')
    .catch _.Error('author_layout fetchWorks err')

  onShow: ->
    @showInfobox()
    if @worksShouldBeShown then @showWorks()
    if @displayMergeSuggestions then @setTimeout @showMergeSuggestions.bind(@), 100

  showInfobox: ->
    @infoboxRegion.show new AuthorInfobox { @model, @standalone }

  showWorks: ->
    startLoading.call @, '.works'

    @model.waitForWorks
    .then @_showWorks.bind(@)

  _showWorks: ->
    { works, series, articles } = @model.works
    total = works.totalLength + series.totalLength + articles.totalLength

    # Always starting wrapped on small screens
    if not screen_.isSmall(600) and total > 0 then @unwrap()

    initialWorksListLength = if @standalone then 10 else 5

    @showWorkCollection 'works', initialWorksListLength

    seriesCount = @model.works.series.totalLength
    if seriesCount > 0 or @standalone
      @showWorkCollection 'series', initialWorksListLength
      # If the author has no series, move the series block down
      if seriesCount is 0 then @seriesRegion.$el.css 'order', 2

    if @model.works.articles.totalLength > 0
      @showWorkCollection 'articles'

  unwrap: -> @$el.removeClass 'wrapped'

  showWorkCollection: (type, initialLength)->
    @["#{type}Region"].show new EntitiesList
      parentModel: @model
      collection: @model.works[type]
      title: type
      type: dropThePlural type
      initialLength: initialLength
      showActions: @options.showActions
      wrapWorks: @options.wrapWorks

  showMergeSuggestions: ->
    app.execute 'show:merge:suggestions', { @model, region: @mergeSuggestionsRegion }

dropThePlural = (type)-> type.replace /s$/, ''
