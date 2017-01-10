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
    # Trigger fetchWorks only once the author is in view
    @$el.once 'inview', @fetchWorks.bind(@)
    if @options.standalone then app.execute 'metadata:update:needed'

  initPlugins: ->
    _.extend @, behaviorsPlugin

  events:
    'click .refreshData': 'refreshData'
    'click .unwrap': 'unwrap'

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone
      canRefreshData: true
      # having an epub download button on an author isn't really interesting
      hideWikisourceEpub: true

  fetchWorks: ->
    @worksShouldBeShown = true
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @model.initAuthorWorks refresh
    .then @_showWorksIfRendered.bind(@)
    .catch _.Error('author_layout fetchWorks err')

  _showWorksIfRendered: ->
    if @isRendered then @showWorks()
    # else, let the onRender hook do it

  onRender: ->
    @showInfobox()
    if @worksShouldBeShown then @showWorks()
    if @options.standalone
      @model.updateMetadata()
      .finally app.Execute('metadata:update:done')

  showInfobox: ->
    @infoboxRegion.show new AuthorInfobox
      model: @model
      standalone: @options.standalone

  showWorks: ->
    # Target specifically .works .loading, so that it doesn't conflict
    # with other loaders as it been seen on genre_layout for instance
    @startLoading '.works'

    @model.waitForWorks
    .then @_showWorks.bind(@)

  _showWorks: ->
    { works, series, articles } = @model.works
    total = works.totalLength + series.totalLength + articles.totalLength

    if total > 0 then @unwrap()

    @showWorkCollection 'works'

    if @model.works.series.totalLength > 0
      initialLength = if @options.standalone then 10 else 5
      @showWorkCollection 'series', initialLength

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
