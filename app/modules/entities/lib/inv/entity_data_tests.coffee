books_ = app.lib.books

module.exports = (data)->
  { title, authors, isbn } = data
  unless _.isNonEmptyString title
    forms_.throwError 'a title is required', '#titleField'

  unless _.isNonEmptyString authors
    forms_.throwError 'an author is required', '#authorsField'

  if _.isNonEmptyString isbn
    unless books_.isIsbn isbn
      forms_.throwError 'invalid ISBN', '.entityCreate #isbnField'
