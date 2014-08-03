ResultsList = require 'views/entities/results_list'

module.exports = class Book extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/book'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}
  initialize: -> @addMultipleSelectorEvents()
  events:
    'click #titleButton': 'titleSearch'
    'click #authorButton': 'authorSearch'
    'click #isbnButton': 'isbnSearch'

  multipleSelectorEvents:
    [['keyup', ['#titleInput', '#authorInput', '#isbnInput'],'onKeyup']]

  onShow: -> app.commands.execute 'foundation:reload'

  onKeyup: (e)->
    if @$el.find('.alert-box').is(':visible')
      @$el.trigger 'hideAlertBox'
    if e.keyCode is 13 && $(e.currentTarget).val().length isnt ''
      switch  e.currentTarget.id
        when 'titleInput' then @titleSearch(e)
        when 'authorInput' then @authorSearch(e)
        when 'isbnInput' then @isbnSearch(e)

  titleSearch: (e)->
    query = $('#titleInput').val()
    @queryAPI 'title', query, notEmpty

  authorSearch: (e)->
    query = $('#authorInput').val()
    @queryAPI 'author', query, notEmpty

  isbnSearch: (e)->
    query = $('#isbnInput').val().trim().replace(/-/g, '').replace(/\s/g, '')
    @queryAPI 'isbn', query, validISBN

  queryAPI: (domain, query, validityTest)=>
    input = "##{domain}Input"
    button = "##{domain}Button"
    if validityTest(query)
      _.log query, 'valid query'
      @$el.trigger 'loading', {selector: button}
      $.getJSON "#{app.API.entities.search}?#{domain}=#{query}"
      .then (resultsArray)=>
        _.log resultsArray, 'resultsArray'
        @results = new Backbone.Collection resultsArray
        resultsList = new ResultsList {collection: @results}
        app.layout.item.creation.preview.show resultsList
        @$el.trigger 'stopLoading', {selector: button}
      .fail (err)=>
        _.log err, 'err'
        _.log [input, button], 'values'
        @$el.trigger 'stopLoading', {selector: button}
        @$el.trigger 'alert', {selector: input, message: 'no item found'}
      .done()
    else
      _.log [input, button], 'rejected'
      @$el.trigger 'alert', {selector: input, message: "invalid #{domain}"}

  notEmpty = (query)-> query.length > 0

  # why the Regexp doesn't catch the empty case?
  validISBN = (query)-> notEmpty(query) && /^([0-9]{10}||[0-9]{13})$/.test query