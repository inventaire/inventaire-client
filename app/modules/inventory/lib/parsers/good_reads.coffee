module.exports = (obj)->
  title: obj.Title
  isbn: cleanIsbn(obj.ISBN13 or obj.ISBN)
  authors: obj.Author.split(',').map _.trim
  details: obj['My Review']
  publisher: obj.Publisher
  publicationDate: if _.isDateString(obj['Year Published']) then obj['Year Published']
  numberOfPages: if _.isPositiveIntegerString(obj['Number of Pages']) then parseInt obj['Number of Pages']
  # See https://www.goodreads.com/api/index#book.id_to_work_id
  goodReadsEditionId: obj['Book Id']

cleanIsbn = (isbn)-> isbn?.replace /("|=)/g, ''
