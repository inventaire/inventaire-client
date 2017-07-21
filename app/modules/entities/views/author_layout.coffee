AuthorInfobox = require './author_infobox'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
WorksList = require './works_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/author_layout'
  className: ->
    # Default to wrapped mode in non standalone mode
    secondClass = if @options.standalone then 'standalone' else 'wrapped'
    return "authorLayout #{secondClass}"

  behaviors:
    Loading: {}

  regions:
    infoboxRegion: '.authorInfobox'
    seriesRegion: '.series'
    worksRegion: '.works'
    articlesRegion: '.articles'

  initialize: ->
    @initPlugins()
    @lazyRender = _.LazyRender @
    { @standalone } = @options
    # Trigger fetchWorks only once the author is in view
    @$el.once 'inview', @fetchWorks.bind(@)

  initPlugins: ->
    _.extend @, behaviorsPlugin

  events:
    'click .refreshData': 'refreshData'
    'click .unwrap': 'unwrap'

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      canRefreshData: true
      # having an epub download button on an author isn't really interesting
      hideWikisourceEpub: true

  fetchWorks: ->
    @worksShouldBeShown = true
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @model.initAuthorWorks refresh
    .then @ifViewIsIntact('showWorks')
    .catch _.Error('author_layout fetchWorks err')

  onRender: ->
    @showInfobox()
    if @worksShouldBeShown then @showWorks()

  showInfobox: ->
    @infoboxRegion.show new AuthorInfobox { @model, @standalone }

  showWorks: ->
    # Target specifically .works .loading, so that it doesn't conflict
    # with other loaders as it been seen on genre_layout for instance
    @startLoading '.works'

    @model.waitForWorks
    .then @_showWorks.bind(@)

  _showWorks: ->
    { works, series, articles } = @model.works
    total = works.totalLength + series.totalLength + articles.totalLength

    # Always starting wrapped on small screens
    if not _.smallScreen(600) and total > 0 then @unwrap()

    @showWorkCollection 'works'

    seriesCount = @model.works.series.totalLength
    if seriesCount > 0 or @standalone
      initialLength = if @standalone then 10 else 5
      @showWorkCollection 'series', initialLength
      # If the author has no series, move the series block down
      if seriesCount is 0 then @seriesRegion.$el.css 'order', 2

    if @model.works.articles.totalLength > 0
      @showWorkCollection 'articles'

  unwrap: -> @$el.removeClass 'wrapped'

  showWorkCollection: (type, initialLength)->
    @["#{type}Region"].show new WorksList
      parentModel: @model
      collection: @model.works[type]
      title: type
      type: dropThePlural type
      initialLength: initialLength

  refreshData: -> app.execute 'show:entity:refresh', @model

dropThePlural = (type)-> type.replace /s$/, ''
