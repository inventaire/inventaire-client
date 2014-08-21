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
    @queryAPI 'book', search, notEmpty

  queryAPI: (domain, search, validityTest)=>
    input = "##{domain}Input"
    button = "##{domain}Button"
    if validityTest(search)
      _.log search, 'valid search'
      @$el.trigger 'loading'
      $.getJSON "#{app.API.entities.search}?claims=[P31:Q571]&search=#{search}&language=#{app.user.lang}"
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
    _.log @, 'this'
    _.log resultsArray, 'resultsArray'

    app.results = {}
    app.results.authors =  authors = resultsArray.map (el)->
      if el.flat.claims?.P31[0]? and el.flat.claims.P31[0] is 'Q5'
        _.log el, 'pushing el to authors'
        return el

    app.results.books = books = resultsArray.map (el)->
      if el.flat.claims?.P31[0]? and el.flat.claims.P31[0] is 'Q571'
        _.log el, 'pushing el to books'
        return el

    # second test needed as .map returns [undefined] instead of [] when empty
    if books.length > 0 and books[0]?
      @books = new Backbone.Collection books
      _.log @books, 'hello books'
      booksList = new ResultsList {collection: @books, type: 'books', entity: 'Q571'}
      app.layout.item.creation.results1.show booksList

    if authors.length > 0 and authors[0]?
      @authors = new Backbone.Collection authors
      _.log @authors, 'hello authors'
      authorsList = new ResultsList {collection: @authors, type: 'authors', entity: 'Q482980'}
      app.layout.item.creation.results2.show authorsList
      @fetchAuthorsBooks(authors[0])

      @$el.trigger 'stopLoading'
      app.request('qLabel:update')

  fetchAuthorsBooks: (author)->
    numericId = author.id.replace(/^Q/,'')
    return $.getJSON "#{app.API.entities.claim}?q=claim[50:#{numericId}]"
    .then (res) ->
      _.log(res, 'entities.claim res')
      if res.items.length > 0
        return getEntities(res.items[0..15], app.user.lang)
      else return
    .then (res)->
      books = []
      _.log res, '#{author.labels.en} books'
      for id,entity of res.entities
        rebaseClaimsValueToClaimsRoot entity
        books.push entity
      author.books = new Backbone.Collection books
      authorBooksList = new ResultsList {collection: author.books, type: 'books', entity: 'Q571'}
      app.layout.item.creation.results3.show authorBooksList

    .fail (err) -> _.log err, 'fetch err'
    .done()

  notEmpty = (query)-> query.length > 0

  # why the Regexp doesn't catch the empty case?
  validISBN = (query)-> notEmpty(query) && /^([0-9]{10}||[0-9]{13})$/.test query


  defaultProps = ['info', 'sitelinks', 'labels', 'descriptions', 'claims']
  getEntities = (ids, languages=['en'], props=defaultProps, format='json')->
    ids = ids.map (id)-> "Q#{id}" unless id[0] is 'Q'
    pipedIds = ids.join '|'
    languages = [languages] if typeof languages is 'string'
    languages.push('en') unless _.hasValue languages, 'en'
    pipedLanguages = languages.join '|'
    pipedProps = props.join '|'
    query = "#{app.API.entities.get}?action=wbgetentities&languages=#{pipedLanguages}&format=#{format}&props=#{pipedProps}&ids=#{pipedIds}".label('getEntities query')
    return $.getJSON(query)

  rebaseClaimsValueToClaimsRoot = (entity)->
    flat =
      claims: new Object
      pictures: new Array
    for id, claim of entity.claims
      # propLabel = wdProps[id]
      flat.claims[id] = new Array
      if typeof claim is 'object'
        claim.forEach (statement)->
          switch statement.mainsnak.datatype
            when 'string'
              flat.claims[id].push(statement._value = statement.mainsnak.datavalue.value)
            when 'wikibase-item'
              statement._id = statement.mainsnak.datavalue.value['numeric-id']
              flat.claims[id].push "Q#{statement._id}"
            else flat.claims[id].push(statement.mainsnak)
          if id is 'P18'
            flat.pictures.push _.wmCommonsThumb(statement.mainsnak.datavalue.value)
      # flat.claims["#{id} - #{propLabel}"] = flat.claims[id]
    entity.flat = flat