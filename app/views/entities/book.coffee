ResultsList = require 'views/entities/results_list'

module.exports = class Book extends Backbone.Marionette.ItemView
  template: require 'views/entities/templates/book'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}
  events:
    'click #searchButton': 'bookSearch'

  onShow: -> app.execute 'foundation:reload'

  bookSearch: (e)->
    search = $('input#search').val()
    _.updateQuery {search: search}
    if app.user.lang?
      @queryAPI search, notEmpty
    else
      _.log 'waiting for lang: query delayed'
      app.user.on 'change:language', => @queryAPI search, notEmpty

  queryAPI: (search, validityTest)=>
    app.results ||= {}
    if app.results.search is search then @displayResult()
    else
      input = "input#search"
      button = "#searchButton"
      if validityTest(search)
        @$el.trigger 'loading'
        $.getJSON app.API.entities.search(search)
        .then @spreadResults
        .then @displayResult
        .fail (err)=>
          _.log err, 'queryAPI err'
          @$el.trigger 'stopLoading'
          @$el.trigger 'alert', {message: _.i18n 'no item found'}
        .done()
      else
        _.log [input, button], 'rejected'
        @$el.trigger 'alert', {message: _.i18n "invalid query"}

  spreadResults: (res)=>
    @$el.trigger 'stopLoading'

    app.results =
      humans: humans = new Backbone.Collection
      authors: authors = new Backbone.Collection
      books: books = new Backbone.Collection
      search: res.search

    _.log res, 'res at spreadResults'
    resultsArray = res.items
    switch res.source
      when 'wd' then @addWikidataEntities(resultsArray)
      when 'google' then @addNonWikidataEntities(resultsArray)
      else throw new Error "couldn't find source: #{res.source}"

  displayResult: ->
    [humans, authors, books] = [app.results.humans, app.results.authors, app.results.books]
    if books.length + authors.length + humans.length > 0
      if books.length > 0
        booksList = new ResultsList {collection: books, type: 'books', entity: 'Q571'}
        app.layout.entities.search.results1.show booksList

      if authors.length is 0
        authors = humans
      if authors.length > 0
        authorsList = new ResultsList {collection: authors, type: 'authors', entity: 'Q482980'}
        app.layout.entities.search.results2.show authorsList
        @fetchAuthorsBooks(authors[0]) if authors[0]?

      if books.length + authors.length is 0
        @$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}

      app.request('qLabel:update')

    else
      @$el.trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}

  addWikidataEntities: (resultsArray)=>
    wdEntities = new app.Collection.WikidataEntities resultsArray

    wdEntities.models.map (el)->
      claims = el.get('claims')

      if claims.P31?[0]?
        app.results.books.add(el) if _.haveAMatch(claims.P31, wd.Q.books)
        app.results.humans.add(el) if _.haveAMatch(claims.P31, wd.Q.humans)

      if claims.P106?[0]?
        app.results.authors.add(el) if _.haveAMatch(claims.P106, wd.Q.authors)

  addNonWikidataEntities: (resultsArray)->
    books = new app.Collection.NonWikidataEntities resultsArray
    books.models.map (el)-> app.results.books.add el

  fetchAuthorsBooks: (author)->
    numericId = author.id.replace(/^Q/,'')
    return $.getJSON "#{app.API.entities.claim}?q=claim[50:#{numericId}]"
    .then (res) ->
      _.log(res, 'entities.claim res')
      if res.items.length > 0
        return app.lib.wikidata.getEntities(res.items[0..15], app.user.lang)
      else return
    .then (res)->
      books = []
      _.log res, '#{author.labels.en} books'
      for id,entity of res.entities
        wd.rebaseClaimsValueToClaimsRoot entity
        books.push entity
      author.books = new Backbone.Collection books
      authorBooksList = new ResultsList {collection: author.books, type: 'books', entity: 'Q571'}
      app.layout.entities.search.results3.show authorBooksList

    .fail (err) -> _.log err, 'fetch err'
    .done()

  notEmpty = (query)-> query.length > 0