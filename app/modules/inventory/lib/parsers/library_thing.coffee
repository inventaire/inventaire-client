decodeHtmlEntities = require './decode_html_entities'

module.exports = (obj)->
  isbn: getIsbn obj
  # Sometimes, titles and authors contains HTML entities
  # that need to be cleaned up
  # Ex: the title of https://www.librarything.com/work/347034/details/154577403
  # is exported as "Ty&ouml;p&auml;iv&auml;kirjat"
  title: decodeHtmlEntities obj.title
  authors: getAuthorsString obj
  publicationDate: if _.isDateString(obj.date) then obj.date
  numberOfPages: if _.isPositiveIntegerString(obj.pages) then parseInt obj.pages

getAuthorsString = (obj)->
  { authors } = obj
  unless _.isArray(authors) and authors.length > 0 then return

  return authors
  .map _.property('fl')
  .filter _.isNonNull
  .map decodeHtmlEntities

getIsbn = (obj)->
  { isbn, ean, originalisbn } = obj
  isbn13 = isbn?['2']
  return isbn13 or originalisbn or ean?[0]
