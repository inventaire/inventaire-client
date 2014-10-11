Search = require 'modules/search/layouts/search'
ResultsList = require 'views/entities/results_list'
AuthorsList = require 'views/entities/authors_list'

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
      'search': (queryString)->
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


  searchEntities: (search, region1, region2, alertSelector)->
    _.log search, 'search'
    app.results ||= {}
    app.execute 'show:loader', {region: region1}
    # verifying that the query is not the same as the last one
    # and using the previous results if so
    if app.results.search is search and app.results.books?.length > 0
      displayResults(region1, region2, alertSelector)
      app.layout.main.hide().fadeIn(200)
    else
      $.getJSON app.API.entities.search(search)
      .then (res)->
        _.log res, 'res at searchEntities'
        spreadResults(res)
        # hiding the loader
        region1.empty()
      .then -> displayResults(region1, region2, alertSelector)
      .fail (err)=>
        _.log err, 'searchEntities err'
        $(alertSelector).trigger 'alert', {message: _.i18n 'no item found'}


spreadResults = (res)=>
  app.results =
    humans: new app.Collection.Entities
    authors: new app.Collection.Entities
    books: new app.Collection.Entities
    search: res.search

  _.log res, 'res at spreadResults'
  resultsArray = res.items
  switch res.source
    when 'wd' then addWikidataEntities(resultsArray)
    when 'google' then addNonWikidataEntities(resultsArray)
    else throw new Error "couldn't find source: #{res.source}"

addWikidataEntities = (resultsArray)=>
  # instantiating generic wikidata entities first
  # and only upgrading later on more specific Models
  # as methods on WikidataEntities greatly ease the sorting process
  wdEntities = new app.Collection.WikidataEntities resultsArray
  wdEntities.models.map (model)->
    claims = model.get('claims')
    if _.isntEmpty(claims.P31)
      if wd.isBook(claims.P31)
        model.upgrade('book')
        app.results.books.add model

      if wd.isHuman(claims.P31)
        model.upgrade('author')
        app.results.humans.add model

    if _.isntEmpty(claims.P106)
      if wd.isAuthor(claims.P106)
        model.upgrade('author')
        app.results.authors.add model

addNonWikidataEntities = (resultsArray)->
  books = new app.Collection.NonWikidataEntities resultsArray
  books.models.map (el)-> app.results.books.add el

displayResults = (region1, region2, alertSelector)=>
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
        $(alertSelector).trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}
        region1.empty()

    else
      $(alertSelector).trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}
      region1.empty()
