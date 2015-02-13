module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/find_by_isbn'
  className: 'findByIsbn'
  serializeData: ->
    findByIsbn:
      nameBase: 'isbn'
      field:
        placeholder: _.i18n 'ex: 978-2-07-036822-8'
        dotdotdot: ''
      button:
        icon: 'search'
        classes: 'secondary postfix'
    isMobile: _.isMobile

  events:
    'click #isbnButton': 'searchByIsbn'

  searchByIsbn: ->
    query = $('input#isbnField').val()
    _.log query, 'isbn query'
    app.execute 'search:global', query