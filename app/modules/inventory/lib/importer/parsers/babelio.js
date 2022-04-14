import { trim } from '#lib/utils'
export default obj => ({
  title: obj.Titre,
  authors: obj.Auteur.split(',').map(trim),
  isbn: obj.ISBN,
  details: obj.Critique,

  // Convert 29/02/2012 to 2012-02-29
  publicationDate: obj['Date de publication']?.split('/').reverse().join('-')
})
