AuthorInfobox = require './author_infobox'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
WorksList = require './works_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/author_layout'
  className: 'authorLayout'
  behaviors:
    Loading: {}
    WikiBar: {}

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
    @showWorkCollection 'works'

    if @model.works.series.totalLength > 0
      initialLength = if @options.standalone then 10 else 5
      @showWorkCollection 'series', initialLength

    if @model.works.articles.totalLength > 0
      @showWorkCollection 'articles'

  showWorkCollection: (type, initialLength)->
    @["#{type}Region"].show new WorksList
      collection: @model.works[type]
      type: type
      initialLength: initialLength

  refreshData: -> app.execute 'show:entity:refresh', @model
