ResultsList = require 'views/entities/results_list'
AuthorsList = require 'views/entities/authors_list'

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
      humans: new app.Collection.Entities
      authors: new app.Collection.Entities
      books: new app.Collection.Entities
      search: res.search

    _.log res, 'res at spreadResults'
    resultsArray = res.items
    switch res.source
      when 'wd' then @addWikidataEntities(resultsArray)
      when 'google' then @addNonWikidataEntities(resultsArray)
      else throw new Error "couldn't find source: #{res.source}"

  addWikidataEntities: (resultsArray)=>
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

  displayResults: =>
    [humans, authors, books] = [app.results.humans, app.results.authors, app.results.books]
    if books.length + authors.length + humans.length > 0
      if books.length > 0
        booksList = new ResultsList {collection: books, type: 'books', entity: 'Q571'}
        app.layout.entities.search.results1.show booksList

      if authors.length is 0
        authors = humans
      if authors.length > 0
        authorsList = new AuthorsList {collection: authors}
        app.layout.entities.search.results2.show authorsList

      if books.length + authors.length is 0
        @$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}

      app.request('qLabel:update')

    else
      @$el.trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}


  addNonWikidataEntities: (resultsArray)->
    books = new app.Collection.NonWikidataEntities resultsArray
    books.models.map (el)-> app.results.books.add el