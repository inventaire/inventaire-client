books_ = require 'lib/books'
forms_ = require 'modules/general/lib/forms'

module.exports = (data)->
  { title, authors, isbn } = data
  unless _.isNonEmptyString title
    forms_.throwError 'a title is required', '#titleField', data

  unless _.isNonEmptyString authors
    forms_.throwError 'an author is required', '#authorsField', data

  if _.isNonEmptyString isbn
    unless books_.isIsbn isbn
      forms_.throwError 'invalid ISBN', '.entityCreate #isbnField', data
