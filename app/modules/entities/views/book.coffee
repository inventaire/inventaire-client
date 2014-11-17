module.exports = class Book extends Backbone.Marionette.ItemView
  template: require './templates/book'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}
  events:
    'click #bookSearchButton': 'bookSearch'

  onShow: -> app.execute 'foundation:reload'

  resetResults: ->
    [1,2,3].forEach (num)->
      app.layout.entities.search["results#{num}"].empty()

  serializeData: ->
    bookSearch:
      nameBase: 'bookSearch'
      field:
        placeholder: _.i18n 'ex: Tintin et les Picaros or 978-2070342266'
      button:
        icon: 'search'

  bookSearch: (e)->
    search = $('input#bookSearchField').val()
    _.updateQuery {search: search}
    if app.user.lang? then @queryAPI search
    else
      _.log 'waiting for lang: query delayed'
      app.user.on 'change:language', => @queryAPI search

  queryAPI: (search)=>
    if search.length > 0
      @resetResults()
      [region1, region2] = _.pickToArray(app.layout.entities.search, ['results1', 'results2'])
      app.request 'search:entities', search, region1, region2, @
    else
      @$el.trigger 'alert', {message: _.i18n 'empty query'}

