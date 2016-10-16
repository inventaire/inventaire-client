behaviorsPlugin = require 'modules/general/plugins/behaviors'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'
WorksList = require './works_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/author_li'
  tagName: 'li'
  className: 'authorLi'
  behaviors:
    Loading: {}

  regions:
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
    if @options.standalone then wikiBarPlugin.call @

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
    .catch _.Error('author_li fetchBooks err')

  _showWorksIfRendered: ->
    if @isRendered then @showWorks()
    # else, let the onRender hook do it

  onRender: ->
    if @worksShouldBeShown then @showWorks()
    if @options.standalone
      @model.updateMetadata()
      .finally app.Execute('metadata:update:done')

  showWorks: ->
    @startLoading()

    @model.waitForWorks
    .then @_showWorks.bind(@)

  _showWorks: ->
    @showBooks()
    if @model.works.articles.totalLength > 0 then @showArticles()

  showBooks: ->
    @booksRegion.show new WorksList
      collection: @model.works.books
      type: 'books'

  showArticles: ->
    @articlesRegion.show new WorksList
      collection: @model.works.articles
      type: 'articles'

  refreshData: -> app.execute 'show:entity:refresh', @model
