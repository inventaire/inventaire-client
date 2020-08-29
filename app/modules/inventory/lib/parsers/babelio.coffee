module.exports = (obj)->
  title: obj.Titre
  authors: obj.Auteur.split(',').map _.trim
  isbn: obj.ISBN
  # Convert 29/02/2012 to 2012-02-29
  publicationDate: obj['Date de publication']?.split('/').reverse().join('-')
