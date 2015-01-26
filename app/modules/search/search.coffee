Search = require 'modules/search/layouts/search'
ResultsList = require 'modules/entities/views/results_list'
AuthorsList = require 'modules/entities/views/authors_list'
Entities = require 'modules/entities/collections/entities'
WikidataEntities = require 'modules/entities/collections/wikidata_entities'
IsbnEntities = require 'modules/entities/collections/isbn_entities'
wd = app.lib.wikidata

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    SearchRouter = Marionette.AppRouter.extend
      appRoutes:
        'search': 'search'

    app.addInitializer ->
      new SearchRouter
        controller: API

  initialize: ->
    app.commands.setHandlers
      'search:global': (queryString)->
        API.search(queryString)
        app.navigate "search?#{queryString}"

    app.reqres.setHandlers
      'search:entities': API.searchEntities

API =
  search: (queryString)->
    params =
      query: _.softDecodeURI(queryString)

    app.search = searchLayout = new Search(params)

    docTitle = "#{queryString} - " +  _.i18n('Search')
    app.layout.main.Show searchLayout, docTitle


  searchEntities: (search, region1, region2, view)->
    _.log search, 'search'
    app.results ||= {}
    app.execute 'show:loader', {region: region1}
    # verifying that the query is not the same as the last one
    # and using the previous results if so
    if app.results.search is search and app.results.books?.length > 0
      displayResults(region1, region2, view)
      region1.$el.hide().fadeIn(200)
    else
      _.preq.get app.API.entities.search(search)
      .then (res)->
        _.log res, 'res at searchEntities'
        spreadResults(res)
        # hiding the loader
        region1.empty()
      .then -> displayResults(region1, region2, view)
      .fail (err)=>
        # couldn't make the alert Behavior work properly
        # so the triggerMethod '404' thing is a provisory solution
        view.$el.trigger 'alert', {message: _.i18n 'no item found'}
        view.triggerMethod '404'
        _.log err, 'searchEntities err'
        # if err.status is 404


spreadResults = (res)=>
  app.results =
    humans: new Entities
    authors: new Entities
    books: new Entities
    search: res.search

  resultsArray = res.items
  switch res.source
    when 'wd' then addWikidataEntities(resultsArray)
    when 'google' then addIsbnEntities(resultsArray)
    else throw new Error "couldn't find source: #{res.source}"

addWikidataEntities = (resultsArray)->
  # instantiating generic wikidata entities first
  # and only upgrading later on more specific Models
  # as methods on WikidataEntities greatly ease the sorting process
  wdEntities = new WikidataEntities resultsArray
  wdEntities.models.map (model)->
    claims = model.get('claims')
    if _.isntEmpty(claims.P31)
      if wd.isBook(claims.P31)
        app.results.books.add model

      if wd.isHuman(claims.P31)
        app.results.humans.add model

    if _.isntEmpty(claims.P106)
      if wd.isAuthor(claims.P106)
        app.results.authors.add model

addIsbnEntities = (resultsArray)->
  books = new IsbnEntities resultsArray
  books.models.map (el)-> app.results.books.add el

displayResults = (region1, region2, view)=>
    [humans, authors, books] = [app.results.humans, app.results.authors, app.results.books]
    if books.length + authors.length + humans.length > 0
      if books.length > 0
        booksList = new ResultsList {collection: books, type: 'books', entity: 'Q571'}
        region1.show booksList

      if authors.length is 0
        authors = humans
      if authors.length > 0
        authorsList = new AuthorsList {collection: authors}
        region2.show authorsList

      if books.length + authors.length is 0
        view.$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}
        region1.empty()

    else
      view.$el.trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}
      region1.empty()
