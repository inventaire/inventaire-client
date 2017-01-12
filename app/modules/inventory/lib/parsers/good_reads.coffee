module.exports = (obj)->
  title: obj.Title
  isbn: (obj.ISBN13 or obj.ISBN)?.replace /("|=)/g, ''
  authors: obj.Author
  details: obj['My Review']
