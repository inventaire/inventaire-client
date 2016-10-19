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
    infoboxRegion: '.infobox'
    seriesRegion: '.series'
    booksRegion: '.books'
    articlesRegion: '.articles'

  initialize: ->
    @initPlugins()
    @lazyRender = _.LazyRender @
    # trigger fetchbooks once the author is in view
    @$el.once 'inview', @fetchBooks.bind(@)
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

  fetchBooks: ->
    @worksShouldBeShown = true
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @model.initAuthorWorks refresh
    .then @_showWorksIfRendered.bind(@)
    .catch _.Error('author_layout fetchBooks err')

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
    @infoboxRegion.show new AuthorInfobox { model: @model }

  showWorks: ->
    @startLoading()

    @model.waitForWorks
    .then @_showWorks.bind(@)

  _showWorks: ->
    @showWorkCollection 'books'
    if @model.works.series.totalLength > 0 then @showWorkCollection 'series'
    if @model.works.articles.totalLength > 0 then @showWorkCollection 'articles'

  showWorkCollection: (type)->
    @["#{type}Region"].show new WorksList
      collection: @model.works[type]
      type: type

  refreshData: -> app.execute 'show:entity:refresh', @model
