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

  resetResults: ->
    [1,2,3].forEach (num)->
      app.layout.entities.search["results#{num}"].empty()

  serializeData: ->
    search:
      field:
        id: 'search'
        placeholder: _.i18n 'ex: Tintin et les Picaros or 978-2070342266'
      button:
        id:'searchButton'
        text: _.i18n 'Search'

  bookSearch: (e)->
    search = $('input#search').val()
    _.updateQuery {search: search}
    if app.user.lang? then @queryAPI search
    else
      _.log 'waiting for lang: query delayed'
      app.user.on 'change:language', => @queryAPI search

  queryAPI: (search)=>
    app.results ||= {}
    if app.results.search is search and app.results.books?.length > 0
      @displayResults()
      app.layout.entities.search.results1.$el.hide().fadeIn(200)
    else
      if search.length > 0
        @resetResults()
        @$el.trigger 'loading'
        $.getJSON app.API.entities.search(search)
        .then @spreadResults
        .then @displayResults
        .fail (err)=>
          _.log err, 'queryAPI err'
          @$el.trigger 'stopLoading'
          @$el.trigger 'alert', {message: _.i18n 'no item found'}
        .done()
      else
        @$el.trigger 'alert', {message: _.i18n 'empty query'}

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

  displayResults: =>
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
        if authors.length > 0
          @fetchAuthorsBooks(authors.models[0])

      if books.length + authors.length is 0
        @$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}

      app.request('qLabel:update')

    else
      @$el.trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}

  addWikidataEntities: (resultsArray)=>
    wdEntities = new app.Collection.WikidataEntities resultsArray

    wdEntities.models.map (el)->
      claims = el.get('claims')

      if _.isntEmpty(claims.P31)
        app.results.books.add(el) if _.haveAMatch(claims.P31, wd.Q.books)
        app.results.humans.add(el) if _.haveAMatch(claims.P31, wd.Q.humans)

      if _.isntEmpty(claims.P106)
        app.results.authors.add(el) if _.haveAMatch(claims.P106, wd.Q.authors)

  addNonWikidataEntities: (resultsArray)->
    books = new app.Collection.NonWikidataEntities resultsArray
    books.models.map (el)-> app.results.books.add el

  fetchAuthorsBooks: (author)->
    _.log author, 'author?'
    numericId = author.id.replace(/^Q/,'')
    return $.getJSON _.proxy(wd.API.wmflabs.claim(50, numericId))
    .then (res) ->
      _.log(res, 'entities.claim res')
      if res.items.length > 0
        return wd.getEntities(res.items[0..15], app.user.lang)
      else return
    .then (res)->
      name = _.pickOne(author.get('labels')).value
      _.log res, "#{name}'s books"
      if res?.entities?
        booksEntitiesArray = _.toArray(res.entities)
        author.books = new app.Collection.WikidataEntities booksEntitiesArray
        authorBooksList = new ResultsList {collection: author.books, type: 'books', entity: 'Q571'}
        app.layout.entities.search.results3.show authorBooksList

    .fail (err) -> _.log err, 'fetch err'
    .done()