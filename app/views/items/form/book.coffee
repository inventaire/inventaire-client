ResultsList = require 'views/entities/results_list'

module.exports = class Book extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/book'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}
  events:
    'click #bookButton': 'bookSearch'

  onShow: -> app.execute 'foundation:reload'

  bookSearch: (e)->
    search = $('#bookInput').val()
    _.updateQuery {search: search}
    if app.user.lang?
      @queryAPI search, notEmpty
    else
      _.log 'waiting for lang: query delayed'
      app.user.on 'change:language', => @queryAPI search, notEmpty

  queryAPI: (search, validityTest)=>
    _.log app.user.lang
    input = "#bookInput"
    button = "#bookButton"
    if validityTest(search)
      _.log search, 'valid search'
      @$el.trigger 'loading'
      $.getJSON app.API.entities.search(search)
      .then @displayResults
      .fail (err)=>
        _.log err, 'err'
        @$el.trigger 'stopLoading'
        @$el.trigger 'alert', {message: _.i18n 'no item found'}
      .done()
    else
      _.log [input, button], 'rejected'
      @$el.trigger 'alert', {message: _.i18n "invalid query"}

  displayResults: (resultsArray)=>
    @$el.trigger 'stopLoading'

    app.results = new app.Collection.WikidataEntities resultsArray
    _.log app.results, 'results: WikidataEntities'


    if app.results.length > 0
      _.extend app.results,
        humans: humans = new Backbone.Collection
        authors: authors = new Backbone.Collection
        books: books = new Backbone.Collection

      app.results.models.map (el)->
        claims = el.get('claims')

        if claims.P31?[0]?
          if _.haveAMatch(claims.P31, wd.Q.books)
            books.add el
          if _.haveAMatch(claims.P31, wd.Q.humans)
            humans.add el

        if claims.P106?[0]? and _.haveAMatch(claims.P106, wd.Q.authors)
          authors.add el


      if books.length > 0
        booksList = new ResultsList {collection: books, type: 'books', entity: 'Q571'}
        app.layout.item.creation.results1.show booksList

      if authors.length is 0
        authors = humans
      if authors.length > 0
        authorsList = new ResultsList {collection: authors, type: 'authors', entity: 'Q482980'}
        app.layout.item.creation.results2.show authorsList
        @fetchAuthorsBooks(authors[0]) if authors[0]?

      if books.length + authors.length is 0
        @$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}

      app.request('qLabel:update')

    else
      @$el.trigger 'alert', {message: _.i18n 'no item found (request returned empty)'}



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
      app.layout.item.creation.results3.show authorBooksList

    .fail (err) -> _.log err, 'fetch err'
    .done()

  notEmpty = (query)-> query.length > 0

  # why the Regexp doesn't catch the empty case?
  validISBN = (query)-> notEmpty(query) && /^([0-9]{10}||[0-9]{13})$/.test query

