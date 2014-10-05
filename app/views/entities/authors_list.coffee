ResultsList = require 'views/entities/results_list'

module.exports = class AuthorsList extends ResultsList
  getChildView: -> require 'views/entities/author_li'
  onShow: ->
    @addHeader('authors')
    @showFirstAuthorBooks()

  showFirstAuthorBooks: ->
    firstAuthorView = _.pickOne(@children._views)
    firstAuthorView.displayBooks()