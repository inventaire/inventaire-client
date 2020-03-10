module.exports = (obj)->
  title: obj.Title
  isbn: cleanIsbn(obj.ISBN13 or obj.ISBN)
  authors: obj.Author.split(',').map _.trim
  details: obj['My Review']
  publisher: obj.Publisher
  publicationDate: obj['Year Published']
  numberOfPages: if obj['Number of Pages']? then parseInt obj['Number of Pages']

cleanIsbn = (isbn)-> isbn?.replace /("|=)/g, ''
