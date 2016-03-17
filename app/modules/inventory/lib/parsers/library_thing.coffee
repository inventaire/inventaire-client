module.exports = (obj)->
  { title } = obj
  return data =
    isbn: getIsbn obj
    title: title
    authors: getAuthorsString obj

getAuthorsString = (obj)->
  { primaryauthor, authors } = obj
  if primaryauthor then return primaryauthor
  if _.isArray(authors) and authors.length > 0
    return authors
      .map _.property('fl')
      .join ' ,'

getIsbn = (obj)->
  { isbn, ean, originalisbn } = obj
  isbn13 = isbn?['2']
  return isbn13 or originalisbn or ean?[0]
