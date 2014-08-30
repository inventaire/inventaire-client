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
    @queryAPI search, notEmpty

  queryAPI: (search, validityTest)=>
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

    _.log resultsArray, 'resultsArray'
    if resultsArray?.length? and resultsArray.length > 0
      app.results = {}
      app.results.humans = humans = []
      app.results.authors = authors = []
      app.results.books = books = []

      BooksP31 = [
        'Q571' #book
        'Q2831984' #comic book album
        'Q1004' # bande dessinée
        'Q8261' #roman
        'Q25379' #theatre play
      ]

      resultsArray.map (el)->
        if el.flat.claims?.P31?[0]? and _.hasValue(el.flat.claims.P31, 'Q5')
          _.log el, 'pushing el to humans'
          humans.push el

      resultsArray.map (el)->
        if el.flat.claims?.P106?[0]? and _.hasValue(el.flat.claims.P106, 'Q36180')
          _.log el, 'pushing el to authors'
          authors.push el


      resultsArray.map (el)->
        if el.flat.claims?.P31?[0]? and _.haveAMatch(el.flat.claims.P31, BooksP31)
          _.log el, 'pushing el to books'
          books.push el


      # second test needed as .map returns [undefined] instead of [] when empty
      if books.length > 0 and books[0]?
        @books = new Backbone.Collection books
        _.log @books, 'hello books'
        booksList = new ResultsList {collection: @books, type: 'books', entity: 'Q571'}
        app.layout.item.creation.results1.show booksList

      if authors.length is 0
        authors = humans
      if authors.length > 0 and authors[0]?
        @authors = new Backbone.Collection authors
        _.log @authors, 'hello authors'
        authorsList = new ResultsList {collection: @authors, type: 'authors', entity: 'Q482980'}
        app.layout.item.creation.results2.show authorsList
        @fetchAuthorsBooks(authors[0])

      @$el.trigger 'stopLoading'
      if books.length + authors.length is 0
        @$el.trigger 'alert', {message: _.i18n 'no item found (filtered client-side)'}

      app.request('qLabel:update')

    else
      @$el.trigger 'stopLoading'
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

